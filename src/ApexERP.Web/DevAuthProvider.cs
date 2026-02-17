using Microsoft.AspNetCore.Components.Authorization;
using System.Security.Claims;

namespace ApexERP.Web
{
    public class DevAuthProvider : AuthenticationStateProvider
    {
        public override Task<AuthenticationState> GetAuthenticationStateAsync()
        {
            var identity = new ClaimsIdentity(new[]
            {
                new Claim(ClaimTypes.Name, "Dev User"),
                new Claim(ClaimTypes.Email, "dev@apexerp.local"),
                new Claim(ClaimTypes.Role, "Admin"),
            }, "DevAuth");

            return Task.FromResult(new AuthenticationState(new ClaimsPrincipal(identity)));
        }
    }
}
