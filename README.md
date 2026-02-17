# ApexERP

**Enterprise Resource Planning System**  
Built by [Munyaradzi Chiondegwa](https://github.com/munyaradzichiondegwa/munyaradzichiondegwa)

ApexERP is a comprehensive, modular ERP system designed to streamline operations across diverse sectors — including manufacturing, healthcare, government, retail, finance, and logistics. Inspired by industry leaders like SAP (scalability, modular architecture) and Pastel (user‑friendly accounting and inventory), ApexERP integrates core business functions into a unified platform with real‑time data sharing, process automation, and decision‑making support.

---

## ✨ Key Features

- **Modular Architecture** – Finance, HR, Supply Chain, Inventory, CRM, and more.
- **Role‑Based Access Control (RBAC)** – Fine‑grained permissions for enterprise security.
- **Workflow Automation** – Approvals, procurement, and task routing.
- **Real‑Time Dashboards** – Role‑specific KPIs and alerts.
- **Integration Ready** – REST APIs, OAuth2/OpenID Connect, gRPC, and event‑driven messaging.
- **Compliance** – GDPR, SOX, ISO 27001 with audit trails and encryption.

---

## 🧱 Technology Stack

- **Frontend**: Blazor WebAssembly + MudBlazor (responsive SPAs), SignalR for live updates.
- **Backend**: ASP.NET Core microservices (.NET 8+), Entity Framework Core.
- **Database**: PostgreSQL (primary), SQL Server (HA clusters), Cosmos DB (NoSQL logs).
- **API Gateway**: Ocelot / YARP.
- **Background Jobs**: Hangfire.
- **Workflow**: WorkflowCore / Elsa.
- **Reporting**: Power BI / RDLC, ML.NET for forecasting.
- **Caching**: Redis.
- **DevOps**: Docker, Kubernetes, Azure DevOps / GitLab CI/CD.
- **Monitoring**: Application Insights / ELK, Azure Key Vault.

---

## 📁 Project Structure (Monorepo)

ApexERP/
├── src/ # Source code
│ ├── ApexERP.Shared/ # DTOs, enums, constants
│ ├── ApexERP.Infrastructure/ # DB context, repositories, shared services
│ ├── ApexERP.Api.Gateway/ # API Gateway (routing, auth)
│ ├── ApexERP.Finance/ # Finance microservice
│ ├── ApexERP.HR/ # Human Resources microservice
│ ├── ApexERP.SupplyChain/ # Supply Chain microservice
│ ├── ApexERP.Inventory/ # Inventory microservice
│ ├── ApexERP.CRM/ # CRM microservice
│ ├── ApexERP.Web/ # Blazor WebAssembly frontend
│ │ ├── Modules/ # Per‑module pages (Finance/, HR/, etc.)
│ │ ├── Services/ # API client services
│ │ └── wwwroot/ # Static assets
│ └── ApexERP.BackgroundJobs/ # Hangfire jobs
├── tests/ # Test projects
│ ├── ApexERP.Finance.Tests/
│ ├── ApexERP.Web.Tests/
│ └── ApexERP.Integration.Tests/
├── docs/ # Documentation
│ ├── requirements.md
│ ├── api-docs/
│ └── user-guide/
├── deployment/ # Infrastructure as code
│ ├── kubernetes/
│ ├── docker-compose.yml
│ └── terraform/
├── .github/workflows/ # CI/CD pipelines
└── ApexERP.sln


---

## 🧩 Core Modules & Pages

| Module              | Key Pages                                                                 |
|---------------------|---------------------------------------------------------------------------|
| **Dashboard**       | `Dashboard.razor` – Role‑based KPIs, alerts, quick links.                |
| **Finance**         | Ledger, AP/AR, Invoices, Budgeting, Approvals, Reports.                  |
| **Human Resources** | Employees, Leave Requests, Payroll, Performance Reviews.                  |
| **Supply Chain**    | Vendors, Purchase Orders, PO Approvals, Contracts.                        |
| **Inventory**       | Stock Tracking, Adjustments, Warehouse Ops, Analytics.                    |
| **CRM**             | Pipeline, Leads, Customers, Sales Orders.                                 |
| **Projects**        | Project List, Task Board.                                                 |
| **Assets**          | Fixed Assets, Maintenance.                                                |
| **Admin**           | User Management, Roles & Permissions, Audit Log, Settings.                |

All pages include search, filtering, pagination, and export capabilities.

---

## 🚀 Getting Started

### Prerequisites
- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0) (or .NET 10 if updated)
- SQL Server / PostgreSQL
- (Optional) Azure AD tenant for authentication

### Clone & Build
```bash
git clone https://github.com/munyaradzichiondegwa/ApexERP.git
cd ApexERP
dotnet restore
dotnet build




dotnet run --project src/ApexERP.Web

Navigate to https://localhost:7017 or http://localhost:5072.

📄 License
This project is licensed under the MIT License – see the LICENSE file for details.

👤 Author
Munyaradzi Chiondegwa
GitHub: @munyaradzichiondegwa

For more details, refer to the full proposal document (if available).
"@ | Set-Content -Path README.md -Encoding UTF8
