using System;

namespace CongNghePhanMem_API.DTOs
{
    public class UpdateProfileDto
    {
        public string FullName { get; set; } = null!;
        public DateOnly? DateOfBirth { get; set; }
        public string? Gender { get; set; }
        public string? PhoneNumber { get; set; }
        public string? Address { get; set; }
        public string? BloodType { get; set; }
        public decimal? Height { get; set; }
        public decimal? Weight { get; set; }
    }

    public class AddConditionDto
    {
        public int ConditionId { get; set; }
        public DateTime? DiagnosedDate { get; set; }
        public string? Notes { get; set; }
    }

    public class AddAllergyDto
    {
        public int DrugId { get; set; }
        public string? Severity { get; set; }
        public string? Symptoms { get; set; }
    }

    public class HealthProfileResponseDto
    {
        public string FullName { get; set; } = null!;
        public DateOnly? DateOfBirth { get; set; }
        public string? Gender { get; set; }
        public string? PhoneNumber { get; set; }
        public string? Address { get; set; }
        public string? BloodType { get; set; }
        public decimal? Height { get; set; }
        public decimal? Weight { get; set; }
        public decimal? BMI { get; set; }
    }

    public class PatientConditionResponseDto
    {
        public int PatientConditionId { get; set; }
        public string ConditionName { get; set; } = null!;
        public DateTime? DiagnosedDate { get; set; }
        public string? Notes { get; set; }
    }

    public class PatientAllergyResponseDto
    {
        public int AllergyId { get; set; }
        public string DrugName { get; set; } = null!;
        public string? Severity { get; set; }
        public string? Symptoms { get; set; }
        public DateTime? NotedDate { get; set; }
    }
}