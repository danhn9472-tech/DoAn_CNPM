using Microsoft.EntityFrameworkCore;
using CongNghePhanMem_API.Entities;

namespace CongNghePhanMem_API.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<Patient> Patients { get; set; }
        public DbSet<Doctor> Doctors { get; set; }
        public DbSet<Drug> Drugs { get; set; }
        public DbSet<DrugInteraction> DrugInteractions { get; set; }
        public DbSet<HealthProfile> HealthProfiles { get; set; }
        public DbSet<MedicalCondition> MedicalConditions { get; set; }
        public DbSet<PatientCondition> PatientConditions { get; set; }
        public DbSet<PatientAllergy> PatientAllergies { get; set; }
        public DbSet<Prescription> Prescriptions { get; set; }
        public DbSet<PrescriptionDetail> PrescriptionDetails { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // 1. Cấu hình Enum sang String để khớp với đặc tả DB (VARCHAR/NVARCHAR)
            modelBuilder.Entity<User>()
                .Property(u => u.Role)
                .HasConversion<string>();

            modelBuilder.Entity<DrugInteraction>()
                .Property(di => di.SeverityLevel)
                .HasConversion<string>();

            modelBuilder.Entity<Prescription>()
                .Property(p => p.Status)
                .HasConversion<string>();

            // 2. Cấu hình Quan hệ 1-1 (User - Patient)
            modelBuilder.Entity<Patient>()
                .HasOne(p => p.User)
                .WithOne(u => u.Patient)
                .HasForeignKey<Patient>(p => p.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // 3. Cấu hình Quan hệ 1-1 (User - Doctor)
            modelBuilder.Entity<Doctor>()
                .HasOne(d => d.User)
                .WithOne(u => u.Doctor)
                .HasForeignKey<Doctor>(d => d.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // 4. Cấu hình Quan hệ 1-1 (Patient - HealthProfile)
            modelBuilder.Entity<HealthProfile>()
                .HasOne(hp => hp.Patient)
                .WithOne(p => p.HealthProfile)
                .HasForeignKey<HealthProfile>(hp => hp.PatientId)
                .OnDelete(DeleteBehavior.Cascade);

            // 5. Cấu hình Quan hệ Tự tham chiếu (Drug Interactions)
            // Cần đặt DeleteBehavior.Restrict để tránh lỗi "multiple cascade paths" trong SQL Server
            modelBuilder.Entity<DrugInteraction>(entity =>
            {
                entity.HasOne(di => di.Drug1)
                    .WithMany(d => d.InteractionsAsPrimary)
                    .HasForeignKey(di => di.DrugId1)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(di => di.Drug2)
                    .WithMany(d => d.InteractionsAsSecondary)
                    .HasForeignKey(di => di.DrugId2)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            // 6. Cấu hình Decimal Precision cho Health Profile
            modelBuilder.Entity<HealthProfile>(entity =>
            {
                entity.Property(e => e.Height).HasPrecision(5, 2);
                entity.Property(e => e.Weight).HasPrecision(5, 2);
            });

            // 7. Cấu hình Unique Constraint cho Username
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Username)
                .IsUnique();

            // 8. Ràng buộc nghiệp vụ QĐ1: Tuổi bệnh nhân (Sử dụng Check Constraint nếu DB hỗ trợ)
            // Lưu ý: EF Core hỗ trợ HasCheckConstraint cho SQL Server
            modelBuilder.Entity<Patient>()
                .ToTable(t => t.HasCheckConstraint("CK_Patient_Age", "DATEDIFF(YEAR, DateOfBirth, GETDATE()) > 0 AND DATEDIFF(YEAR, DateOfBirth, GETDATE()) < 120"));
        }
    }
}