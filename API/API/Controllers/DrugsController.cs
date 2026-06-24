using CongNghePhanMem_API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace CongNghePhanMem_API.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class DrugsController : ControllerBase
    {
        private readonly IDrugService _drugService;

        public DrugsController(IDrugService drugService)
        {
            _drugService = drugService;
        }

        [HttpGet("search")]
        public async Task<IActionResult> Search([FromQuery] string keyword)
        {
            var results = await _drugService.SearchDrugsAsync(keyword);
            return Ok(results);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var drug = await _drugService.GetDrugByIdAsync(id);
            if (drug == null) return NotFound("Không tìm thấy thông tin thuốc.");
            return Ok(drug);
        }
    }
}