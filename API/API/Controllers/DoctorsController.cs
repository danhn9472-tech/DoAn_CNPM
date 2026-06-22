using CongNghePhanMem_API.DTOs;
using CongNghePhanMem_API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace CongNghePhanMem_API.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class DoctorsController : ControllerBase
    {
        private readonly IDoctorService _doctorService;

        public DoctorsController(IDoctorService doctorService)
        {
            _doctorService = doctorService;
        }

        [HttpGet("search")]
        public async Task<IActionResult> SearchDoctors([FromQuery] string keyword)
        {
            var results = await _doctorService.SearchDoctorsAsync(keyword);
            return Ok(results);
        }
    }
}
