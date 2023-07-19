using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.DataContracts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.Collections;
using System.Collections.Generic;

namespace generator.Controllers
{
    public class SystemController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private readonly TelemetryClient _telemetryClient;
        public SystemController(ILogger<HomeController> logger)
        {
            _logger = logger;
            _telemetryClient = new TelemetryClient();
        }

        private void GenerateEnvironmentVariablesTable()
        {
            List<string[]> variables = new List<string[]>();
            foreach (DictionaryEntry de in Environment.GetEnvironmentVariables())
            {
                var variable = new string[] { de.Key.ToString(), de.Value.ToString() };
                variables.Add(variable);
            }

            // Sort variables by variable name
            ViewBag.Variables = variables.OrderBy(o => o[0]);
        }


        private void GenerateFilesTable()
        {
            try
            {
                string[] files = Directory.GetFiles("/mnt/images");
                ViewBag.Files = files;
            }
            catch (Exception ex) 
            {
                _telemetryClient.TrackException(ex);
                _logger.LogError(ex.Message);
            }
        }


        public IActionResult Index()
        {
            GenerateEnvironmentVariablesTable();
            GenerateFilesTable();
            ViewBag.AppName = Environment.GetEnvironmentVariable("CONTAINER_APP_NAME");
            return View();
        }

    }
}
