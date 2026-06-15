using CongNghePhanMem_API.Entities;
using System;
using System.Collections.Generic;

namespace CongNghePhanMem_API.DTOs
{
    public class CreatePrescriptionDto
    {
        public string? Diagnosis { get; set; }
        public int? DoctorId { get; set; }
        public string? Notes { get; set; }
    }

    public class AddDrugDto
    {
        public int DrugId { get; set; }
        public string? Dosage { get; set; }
        public string? Frequency { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
    }

    public class PrescriptionResponseDto
    {
        public int PrescriptionId { get; set; }
        public string? Diagnosis { get; set; }
        public DateTime CreatedDate { get; set; }
        public string Status { get; set; } = null!;
        public string? DoctorName { get; set; }
    }

    public class PrescriptionDetailResponseDto
    {
        public int PrescriptionId { get; set; }
        public string? Diagnosis { get; set; }
        public DateTime CreatedDate { get; set; }
        public string Status { get; set; } = null!;
        public string? DoctorName { get; set; }
        public string? Notes { get; set; }
        public List<DrugItemResponseDto> Items { get; set; } = new();
    }

    public class DrugItemResponseDto
    {
        public int DrugId { get; set; }
        public string DrugName { get; set; } = null!;
        public string? Dosage { get; set; }
        public string? Frequency { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
    }

    public class ConflictWarningDto
    {
        public string Type { get; set; } = null!; // Allergy, Interaction, Condition
        public string Severity { get; set; } = null!;
        public string Description { get; set; } = null!;
    }

    public class PrescriptionActionResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; } = null!;
        public List<ConflictWarningDto>? Conflicts { get; set; }
    }
}