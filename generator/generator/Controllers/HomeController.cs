using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using generator.Models;
using Newtonsoft.Json.Linq;
using Microsoft.Extensions.Logging;
using System.Collections;
using System.Net;

namespace generator.Controllers;

public class HomeController : Controller
{
    private readonly ILogger<HomeController> _logger;

    public HomeController(ILogger<HomeController> logger)
    {
        _logger = logger;
    }

    public IActionResult Index(string id)
    {
        string environmentColor = "";
        try
        {
            environmentColor = Environment.GetEnvironmentVariable("Environment");
        }
        catch(Exception ex)
        {
            _logger.LogError(ex.ToString());
        }

        if (!string.IsNullOrWhiteSpace(id))
        {
            environmentColor = id;
        }

        ViewBag.EnvironmentColor = environmentColor;

        ViewBag.AppName = Environment.GetEnvironmentVariable("CONTAINER_APP_NAME");
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
