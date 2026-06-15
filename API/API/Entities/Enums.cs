namespace CongNghePhanMem_API.Entities
{
    public enum UserRole
    {
        Admin,
        Doctor,
        Patient
    }

    public enum InteractionSeverity
    {
        ChongChiDinh, // Chống chỉ định
        NghiemTrong,  // Nghiêm trọng
        Nhe           // Nhẹ
    }

    public enum PrescriptionStatus
    {
        DangUong,   // Đang uống
        DaDung,     // Đã dừng
        ChoDuyet    // Chờ duyệt
    }
}