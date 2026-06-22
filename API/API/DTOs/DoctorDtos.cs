using System.ComponentModel.DataAnnotations;

namespace CongNghePhanMem_API.DTOs
{
    public class DoctorSearchResponseDto
    {
        public int DoctorId { get; set; }
        public string FullName { get; set; } = null!;
        public string? Specialty { get; set; }
        public string? Workplace { get; set; }
    }
}
