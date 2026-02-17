using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System.Threading.Tasks;

namespace ApexERP.BackgroundJobs
{
    public class Program
    {
        public static async Task Main(string[] args)
        {
            var host = Host.CreateDefaultBuilder(args)
                .ConfigureServices(services =>
                {
                    // Register background services here
                    // Example: services.AddHostedService<Worker>();
                })
                .Build();

            await host.RunAsync();
        }
    }
}
