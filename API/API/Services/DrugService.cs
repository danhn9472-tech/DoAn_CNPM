using CongNghePhanMem_API.Data;
using CongNghePhanMem_API.DTOs;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace CongNghePhanMem_API.Services
{
    public class DrugService : IDrugService
    {
        private readonly AppDbContext _context;

        public DrugService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<DrugSearchResponseDto>> SearchDrugsAsync(string keyword)
        {
            if (string.IsNullOrWhiteSpace(keyword)) return new List<DrugSearchResponseDto>();

            return await _context.Drugs
                .Where(d => d.DrugName.Contains(keyword) || (d.ActiveIngredient != null && d.ActiveIngredient.Contains(keyword)))
                .Select(d => new DrugSearchResponseDto
                {
                    DrugId = d.DrugId,
                    DrugName = d.DrugName,
                    ActiveIngredient = d.ActiveIngredient
                })
                .ToListAsync();
        }

        public async Task<DrugDetailDto?> GetDrugByIdAsync(int id)
        {
            var drug = await _context.Drugs.FindAsync(id);
            if (drug == null) return null;

            return new DrugDetailDto
            {
                DrugId = drug.DrugId,
                DrugName = drug.DrugName,
                ActiveIngredient = drug.ActiveIngredient,
                Instruction = drug.Instruction,
                SideEffects = drug.SideEffects
            };
        }
    }
}