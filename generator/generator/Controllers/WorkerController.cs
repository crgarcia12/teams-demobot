using Microsoft.ApplicationInsights;
using Microsoft.AspNetCore.Mvc;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace generator.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class WorkerController : ControllerBase
    {

        // GET: api/<WorkerController>
        [HttpGet]
        public async Task<int> Get()
        {
            var rand = new Random();
            int value = rand.Next(0, 10);
            // found it :) 
            int number = 12 / value;
            Console.WriteLine(number);
            return value;
        }


    }
}
