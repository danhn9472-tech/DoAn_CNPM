using CongNghePhanMem_API.Data;
using CongNghePhanMem_API.DTOs;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace CongNghePhanMem_API.Services
{
    public class DoctorService : IDoctorService
    {
        private readonly AppDbContext _context;

        public DoctorService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<DoctorSearchResponseDto>> SearchDoctorsAsync(string keyword)
        {
            if (string.IsNullOrWhiteSpace(keyword)) return new List<DoctorSearchResponseDto>();

            return await _context.Doctors
                .Where(d => d.FullName.StartsWith(keyword) || (d.Specialty != null && d.Specialty.StartsWith(keyword)))
                .Select(d => new DoctorSearchResponseDto
                {
                    DoctorId = d.DoctorId,
                    FullName = d.FullName,
                    Specialty = d.Specialty,
                    Workplace = d.Workplace
                })
                .Take(5)
                .ToListAsync();
        }
    }
}
