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

        public async Task<int> AddDrugAsync(DrugBaseDto dto)
        {
            var drug = new Drug
            {
                DrugName = dto.DrugName,
                ActiveIngredient = dto.ActiveIngredient,
                Instruction = dto.Instruction,
                SideEffects = dto.SideEffects
            };

            _context.Drugs.Add(drug);
            await _context.SaveChangesAsync();
            return drug.DrugId;
        }

        public async Task<bool> UpdateDrugAsync(int id, DrugBaseDto dto)
        {
            var drug = await _context.Drugs.FindAsync(id);
            if (drug == null) return false;

            drug.DrugName = dto.DrugName;
            drug.ActiveIngredient = dto.ActiveIngredient;
            drug.Instruction = dto.Instruction;
            drug.SideEffects = dto.SideEffects;

            _context.Drugs.Update(drug);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<IEnumerable<DrugInteractionResponseDto>> GetAllDrugInteractionsAsync()
        {
            return await _context.DrugInteractions
                .Include(di => di.Drug1)
                .Include(di => di.Drug2)
                .Select(di => new DrugInteractionResponseDto
                {
                    InteractionId = di.InteractionId,
                    DrugId1 = di.DrugId1,
                    DrugName1 = di.Drug1.DrugName,
                    DrugId2 = di.DrugId2,
                    DrugName2 = di.Drug2.DrugName,
                    SeverityLevel = di.SeverityLevel.ToString(),
                    InteractionEffect = di.InteractionEffect,
                    Recommendation = di.Recommendation
                })
                .ToListAsync();
        }

        public async Task<int> AddDrugInteractionAsync(CreateInteractionRuleDto dto)
        {
            // Kiểm tra xem DrugId1 và DrugId2 có tồn tại không
            var drug1Exists = await _context.Drugs.AnyAsync(d => d.DrugId == dto.DrugId1);
            var drug2Exists = await _context.Drugs.AnyAsync(d => d.DrugId == dto.DrugId2);

            if (!drug1Exists || !drug2Exists)
            {
                throw new ArgumentException("Một hoặc cả hai DrugId không tồn tại.");
            }

            var interaction = new DrugInteraction
            {
                DrugId1 = dto.DrugId1,
                DrugId2 = dto.DrugId2,
                SeverityLevel = dto.SeverityLevel,
                InteractionEffect = dto.InteractionEffect,
                Recommendation = dto.Recommendation
            };

            _context.DrugInteractions.Add(interaction);
            await _context.SaveChangesAsync();

            return interaction.InteractionId;
        }

        public async Task<bool> UpdateDrugInteractionAsync(int id, CreateInteractionRuleDto dto)
        {
            var interaction = await _context.DrugInteractions.FindAsync(id);
            if (interaction == null) return false;

            // Kiểm tra xem các DrugId mới có tồn tại trong danh mục thuốc không
            var drug1Exists = await _context.Drugs.AnyAsync(d => d.DrugId == dto.DrugId1);
            var drug2Exists = await _context.Drugs.AnyAsync(d => d.DrugId == dto.DrugId2);

            if (!drug1Exists || !drug2Exists)
            {
                throw new ArgumentException("Một hoặc cả hai DrugId không tồn tại.");
            }

            interaction.DrugId1 = dto.DrugId1;
            interaction.DrugId2 = dto.DrugId2;
            interaction.SeverityLevel = dto.SeverityLevel;
            interaction.InteractionEffect = dto.InteractionEffect;
            interaction.Recommendation = dto.Recommendation;

            _context.DrugInteractions.Update(interaction);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> DeleteDrugInteractionAsync(int id)
        {
            var interaction = await _context.DrugInteractions.FindAsync(id);
            if (interaction == null) return false;

            _context.DrugInteractions.Remove(interaction);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}