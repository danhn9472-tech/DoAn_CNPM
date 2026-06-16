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
    public class ProfileService : IProfileService
    {
        private readonly AppDbContext _context;

        public ProfileService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<HealthProfileResponseDto?> GetMyProfileAsync(int userId)
        {
            var patient = await _context.Patients
                .Include(p => p.HealthProfile)
                .FirstOrDefaultAsync(p => p.UserId == userId);

            if (patient == null) return null;

            var response = new HealthProfileResponseDto
            {
                FullName = patient.FullName,
                DateOfBirth = patient.DateOfBirth,
                Gender = patient.Gender,
                PhoneNumber = patient.PhoneNumber,
                Address = patient.Address,
                BloodType = patient.HealthProfile?.BloodType,
                Height = patient.HealthProfile?.Height,
                Weight = patient.HealthProfile?.Weight
            };

            // Logic QĐ: Tự động tính BMI = Cân nặng (kg) / (Chiều cao (m) ^ 2)
            if (patient.HealthProfile != null && patient.HealthProfile.Height > 0 && patient.HealthProfile.Weight > 0)
            {
                var heightInMeters = (double)patient.HealthProfile.Height / 100.0;
                var weight = (double)patient.HealthProfile.Weight;
                var bmi = weight / (heightInMeters * heightInMeters);
                response.BMI = (decimal)Math.Round(bmi, 2);
            }

            return response;
        }

        public async Task<bool> UpdateProfileAsync(int userId, UpdateProfileDto dto)
        {
            var patient = await _context.Patients
                .Include(p => p.HealthProfile)
                .FirstOrDefaultAsync(p => p.UserId == userId);
            if (patient == null) return false;

            patient.FullName = dto.FullName;
            patient.DateOfBirth = dto.DateOfBirth;
            patient.Gender = dto.Gender;
            patient.PhoneNumber = dto.PhoneNumber;
            patient.Address = dto.Address;

            if (patient.HealthProfile == null)
            {
                patient.HealthProfile = new HealthProfile
                {
                    BloodType = dto.BloodType,
                    Height = dto.Height,
                    Weight = dto.Weight,
                    LastUpdated = DateTime.Now
                };
            }
            else
            {
                patient.HealthProfile.BloodType = dto.BloodType;
                patient.HealthProfile.Height = dto.Height;
                patient.HealthProfile.Weight = dto.Weight;
                patient.HealthProfile.LastUpdated = DateTime.Now;
            }

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<IEnumerable<PatientConditionResponseDto>> GetConditionsAsync(int userId)
        {
            return await _context.PatientConditions
                .Where(pc => pc.Patient.UserId == userId)
                .Select(pc => new PatientConditionResponseDto
                {
                    PatientConditionId = pc.PatientConditionId,
                    ConditionName = pc.MedicalCondition.ConditionName,
                    DiagnosedDate = pc.DiagnosedDate,
                    Notes = pc.Notes
                })
                .ToListAsync();
        }

        public async Task<bool> AddConditionAsync(int userId, AddConditionDto dto)
        {
            var patient = await _context.Patients.FirstOrDefaultAsync(p => p.UserId == userId);
            if (patient == null) return false;

            var condition = new PatientCondition
            {
                PatientId = patient.PatientId,
                ConditionId = dto.ConditionId,
                DiagnosedDate = dto.DiagnosedDate,
                Notes = dto.Notes
            };

            _context.PatientConditions.Add(condition);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> RemoveConditionAsync(int userId, int patientConditionId)
        {
            var condition = await _context.PatientConditions
                .FirstOrDefaultAsync(pc => pc.PatientConditionId == patientConditionId && pc.Patient.UserId == userId);

            if (condition == null) return false;

            _context.PatientConditions.Remove(condition);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<IEnumerable<PatientAllergyResponseDto>> GetAllergiesAsync(int userId)
        {
            return await _context.PatientAllergies
                .Where(pa => pa.Patient.UserId == userId)
                .Select(pa => new PatientAllergyResponseDto
                {
                    AllergyId = pa.AllergyId,
                    DrugName = pa.Drug.DrugName,
                    Severity = pa.Severity,
                    Symptoms = pa.Symptoms,
                    NotedDate = pa.NotedDate
                })
                .ToListAsync();
        }

        public async Task<bool> AddAllergyAsync(int userId, AddAllergyDto dto)
        {
            var patient = await _context.Patients.FirstOrDefaultAsync(p => p.UserId == userId);
            if (patient == null) return false;

            // Logic QĐ: Kiểm tra xem thuốc này đã có trong danh sách dị ứng chưa
            var exists = await _context.PatientAllergies
                .AnyAsync(pa => pa.PatientId == patient.PatientId && pa.DrugId == dto.DrugId);
            
            if (exists) return false;

            var allergy = new PatientAllergy
            {
                PatientId = patient.PatientId,
                DrugId = dto.DrugId,
                Severity = dto.Severity,
                Symptoms = dto.Symptoms,
                NotedDate = DateTime.Now
            };

            _context.PatientAllergies.Add(allergy);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<IEnumerable<ConditionSearchResponseDto>> SearchConditionsAsync(string keyword)
        {
            if (string.IsNullOrWhiteSpace(keyword)) return new List<ConditionSearchResponseDto>();

            return await _context.MedicalConditions
                .Where(c => c.ConditionName.Contains(keyword))
                .Select(c => new ConditionSearchResponseDto
                {
                    ConditionId = c.ConditionId,
                    ConditionName = c.ConditionName
                })
                .Take(10)
                .ToListAsync();
        }

        public async Task<IEnumerable<PatientAllergyResponseDto>> SearchMyAllergiesAsync(int userId, string keyword)
        {
            var query = _context.PatientAllergies
                .Where(pa => pa.Patient.UserId == userId);

            if (!string.IsNullOrWhiteSpace(keyword))
            {
                query = query.Where(pa => pa.Drug.DrugName.Contains(keyword));
            }

            return await query.Select(pa => new PatientAllergyResponseDto
            {
                AllergyId = pa.AllergyId,
                DrugName = pa.Drug.DrugName,
                Severity = pa.Severity,
                Symptoms = pa.Symptoms,
                NotedDate = pa.NotedDate
            }).ToListAsync();
        }
    }
}