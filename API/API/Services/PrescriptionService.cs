using CongNghePhanMem_API.Data;
using CongNghePhanMem_API.DTOs;
using CongNghePhanMem_API.Entities;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace CongNghePhanMem_API.Services
{
    public class PrescriptionService : IPrescriptionService
    {
        private readonly AppDbContext _context;

        public PrescriptionService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<PrescriptionResponseDto>> GetPrescriptionsAsync(int userId, string? status)
        {
            var query = _context.Prescriptions
                .Where(p => p.Patient.UserId == userId)
                .AsQueryable();

            if (!string.IsNullOrEmpty(status))
            {
                if (status.Equals("Active", StringComparison.OrdinalIgnoreCase))
                    query = query.Where(p => p.Status == PrescriptionStatus.DangUong);
                else if (status.Equals("Expired", StringComparison.OrdinalIgnoreCase))
                    query = query.Where(p => p.Status == PrescriptionStatus.DaDung);
            }

            return await query.Select(p => new PrescriptionResponseDto
            {
                PrescriptionId = p.PrescriptionId,
                Diagnosis = p.Diagnosis,
                CreatedDate = p.CreatedDate,
                Status = p.Status.ToString(),
                DoctorName = p.Doctor != null ? p.Doctor.FullName : "N/A"
            }).ToListAsync();
        }

        public async Task<PrescriptionDetailResponseDto?> GetPrescriptionByIdAsync(int userId, int prescriptionId)
        {
            var p = await _context.Prescriptions
                .Include(p => p.Doctor)
                .Include(p => p.PrescriptionDetails)
                    .ThenInclude(pd => pd.Drug)
                .FirstOrDefaultAsync(p => p.PrescriptionId == prescriptionId && p.Patient.UserId == userId);

            if (p == null) return null;

            return new PrescriptionDetailResponseDto
            {
                PrescriptionId = p.PrescriptionId,
                Diagnosis = p.Diagnosis,
                CreatedDate = p.CreatedDate,
                Status = p.Status.ToString(),
                DoctorName = p.Doctor?.FullName,
                Notes = p.Notes,
                Items = p.PrescriptionDetails.Select(pd => new DrugItemResponseDto
                {
                    DrugId = pd.DrugId,
                    DrugName = pd.Drug.DrugName,
                    Dosage = pd.Dosage,
                    Frequency = pd.Frequency,
                    StartDate = pd.StartDate,
                    EndDate = pd.EndDate
                }).ToList()
            };
        }

        public async Task<int> CreatePrescriptionAsync(int userId, CreatePrescriptionDto dto)
        {
            var patient = await _context.Patients.FirstOrDefaultAsync(p => p.UserId == userId);
            if (patient == null) throw new Exception("Không tìm thấy bệnh nhân.");

            var prescription = new Prescription
            {
                PatientId = patient.PatientId,
                DoctorId = dto.DoctorId,
                Diagnosis = dto.Diagnosis,
                Notes = dto.Notes,
                Status = PrescriptionStatus.ChoDuyet, // Trạng thái chờ (Draft)
                CreatedDate = DateTime.Now
            };

            _context.Prescriptions.Add(prescription);
            await _context.SaveChangesAsync();
            return prescription.PrescriptionId;
        }

        public async Task<PrescriptionActionResponse> AddDrugToPrescriptionAsync(int userId, int prescriptionId, AddDrugDto dto)
        {
            var prescription = await _context.Prescriptions
                .Include(p => p.PrescriptionDetails)
                .FirstOrDefaultAsync(p => p.PrescriptionId == prescriptionId && p.Patient.UserId == userId);

            if (prescription == null) return new PrescriptionActionResponse { Success = false, Message = "Không tìm thấy đơn thuốc." };

            var conflicts = new List<ConflictWarningDto>();

            // BƯỚC 1: Kiểm tra Tiền sử dị ứng
            // SELECT * FROM PatientAllergies WHERE PatientId = @PatientId AND DrugId = @DrugXId
            var allergy = await _context.PatientAllergies
                .Include(a => a.Drug)
                .FirstOrDefaultAsync(pa => pa.PatientId == prescription.PatientId && pa.DrugId == dto.DrugId);
            
            if (allergy != null)
            {
                conflicts.Add(new ConflictWarningDto { Type = "Allergy", Severity = "High", Description = $"Bệnh nhân dị ứng với {allergy.Drug.DrugName}. Triệu chứng: {allergy.Symptoms}" });
            }

            // BƯỚC 2: Kiểm tra Tương tác Thuốc - Thuốc
            // Lấy danh sách DrugId từ đơn hiện tại VÀ các đơn có trạng thái 'DangUong'
            var activeDrugIdsFromOtherPrescriptions = await _context.PrescriptionDetails
                .Where(pd => pd.Prescription.PatientId == prescription.PatientId && 
                             pd.Prescription.Status == PrescriptionStatus.DangUong && 
                             pd.PrescriptionId != prescriptionId)
                .Select(pd => pd.DrugId)
                .ToListAsync();

            var currentPrescriptionDrugIds = prescription.PrescriptionDetails.Select(pd => pd.DrugId).ToList();
            
            // Danh sách thuốc đang dùng tổng hợp (@DanhSachThuocDangUong)
            var allActiveDrugIds = activeDrugIdsFromOtherPrescriptions.Union(currentPrescriptionDrugIds).Distinct().ToList();

            var interactions = await _context.DrugInteractions
                .Where(di => (di.DrugId1 == dto.DrugId && allActiveDrugIds.Contains(di.DrugId2)) ||
                             (di.DrugId2 == dto.DrugId && allActiveDrugIds.Contains(di.DrugId1)))
                .ToListAsync();

            foreach (var inter in interactions)
            {
                conflicts.Add(new ConflictWarningDto 
                { 
                    Type = "Interaction", 
                    Severity = inter.SeverityLevel.ToString(), 
                    Description = $"Tương tác thuốc: {inter.InteractionEffect}. Khuyến nghị: {inter.Recommendation}" 
                });
            }

            // Nếu phát hiện bất kỳ vi phạm nào ở bước 1 hoặc 2
            if (conflicts.Any())
            {
                return new PrescriptionActionResponse { Success = false, Message = "Phát hiện xung đột hoặc dị ứng.", Conflicts = conflicts };
            }

            // Nếu an toàn: Lưu vào database
            var detail = new PrescriptionDetail
            {
                PrescriptionId = prescriptionId,
                DrugId = dto.DrugId,
                Dosage = dto.Dosage,
                Frequency = dto.Frequency,
                StartDate = dto.StartDate,
                EndDate = dto.EndDate
            };

            _context.PrescriptionDetails.Add(detail);
            await _context.SaveChangesAsync();

            return new PrescriptionActionResponse { Success = true, Message = "Thêm thuốc vào đơn thành công.", Conflicts = conflicts.Any() ? conflicts : null };
        }
    }
}