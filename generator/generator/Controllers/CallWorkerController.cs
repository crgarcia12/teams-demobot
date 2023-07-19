using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.DataContracts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.Collections;
using System.Collections.Generic;

namespace generator.Controllers
{
    public class CallWorkerController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private readonly TelemetryClient _telemetryClient;
        public CallWorkerController(ILogger<HomeController> logger)
        {

            _logger = logger;
            _telemetryClient = new TelemetryClient();
        }

        public IActionResult Index()
        {
            ViewBag.AppName = Environment.GetEnvironmentVariable("CONTAINER_APP_NAME");
            return View();
        }

        public async Task<IActionResult> CallApi(string callMethod)
        {
            using (_logger.BeginScope("Calling the workerAPI"))
            {
                try
                {
                    int[] counters = new int[12];

                    //var baseURL = (Environment.GetEnvironmentVariable("BASE_URL") ?? "http://localhost") + ":" + (Environment.GetEnvironmentVariable("DAPR_HTTP_PORT") ?? "3500");
                    //_logger.LogTrace($"Calling API: '{baseURL}'");                   
                    //client.DefaultRequestHeaders.Add("dapr-app-id", "worker");

                    for (int i = 0; i < 10; i++)
                    {
                        var startTime = DateTime.UtcNow;
                        var timer = System.Diagnostics.Stopwatch.StartNew();
                        try
                        {
                            string response;
                            if (callMethod == "Direct")
                            {
                                var httpResponse = await CallWorkerDirect();
                                response = await httpResponse.Content.ReadAsStringAsync(); 
                                
                            }
                            else
                            {
                                var httpResponse = await CallWorkerDapr();
                                response = await httpResponse.Content.ReadAsStringAsync();
                            }

                            counters[Int32.Parse(response)]++;
                            _telemetryClient.TrackDependency("ExternalCall", "CallingWorker", "workerUrl", DateTime.UtcNow, timer.Elapsed, true);
                        }
                        catch (Exception ex)
                        {

                            _logger.LogError(ex.Message);
                            _telemetryClient.TrackException(ex);
                            counters[11]++;
                            _telemetryClient.TrackDependency("ExternalCall", "CallingWorker", "workerUrl", DateTime.UtcNow, timer.Elapsed, false);
                        }
                    }
                    ViewBag.ApiCounters = counters;

                    ViewBag.AppName = Environment.GetEnvironmentVariable("CONTAINER_APP_NAME");
                    return View("Index");
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex.Message, ex);
                    _telemetryClient.TrackException(ex);
                    throw;
                }
            }
        }

        private async Task<HttpResponseMessage> CallWorkerDirect()
        {
            var httpClient = new HttpClient();
            var workerUrl = "https://worker.livelydesert-273cea00.westeurope.azurecontainerapps.io";

            return await httpClient.GetAsync($"{workerUrl}/api/worker");
        }


        private async Task<HttpResponseMessage> CallWorkerDapr()
        {
            var httpClient = new HttpClient();
            httpClient.DefaultRequestHeaders.Add("dapr-app-id", "worker");

            var workerUrl = "http://localhost:3500";
            return await httpClient.GetAsync($"{workerUrl}/api/worker");
        }
    }
}
