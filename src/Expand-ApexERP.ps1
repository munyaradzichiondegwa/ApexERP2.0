# ============================================================
#  Expand-ApexERP.ps1
#  Run from: C:\Users\chion\Desktop\ApexERP2.0\src\ApexERP.Web
#  Adds: Forms, Detail views, Charts, Approval Workflows
#  for Finance, HR, Supply Chain, Inventory, CRM
# ============================================================

$root = "C:\Users\chion\Desktop\ApexERP2.0\src\ApexERP.Web"
Set-Location $root

function Write-File($path, $content) {
    $dir = Split-Path $path -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Set-Content -Path $path -Value $content -Encoding UTF8
    Write-Host "  [WRITTEN] $path" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  ApexERP - Module Expansion" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# ── FINANCE: Invoice Form ─────────────────────────────────────────────────────
Write-Host "`n[Finance - Invoice Form]" -ForegroundColor Yellow
Write-File "$root\Modules\Finance\InvoiceForm.razor" @'
@page "/finance/invoice/new"
@page "/finance/invoice/{Id}"
@attribute [Authorize]
<PageTitle>Invoice - ApexERP</PageTitle>

<div class="apex-page-header">
    <h1>@(IsNew ? "New Invoice" : $"Invoice {Id}")</h1>
    <div style="display:flex;gap:8px">
        <button class="btn-secondary" @onclick="Cancel">Cancel</button>
        <button class="btn-primary" @onclick="Save">Save Invoice</button>
    </div>
</div>

<div class="form-grid">
    <div class="form-panel">
        <div class="panel-header">Invoice Details</div>
        <div class="form-body">
            <div class="form-row">
                <div class="form-group">
                    <label>Invoice Number</label>
                    <input class="apex-input" @bind="invoice.Number" placeholder="INV-0001" />
                </div>
                <div class="form-group">
                    <label>Invoice Date</label>
                    <input class="apex-input" type="date" @bind="invoice.Date" />
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>Due Date</label>
                    <input class="apex-input" type="date" @bind="invoice.DueDate" />
                </div>
                <div class="form-group">
                    <label>Currency</label>
                    <select class="apex-select" @bind="invoice.Currency">
                        <option>USD</option><option>EUR</option><option>GBP</option><option>ZAR</option>
                    </select>
                </div>
            </div>
            <div class="form-group">
                <label>Customer / Vendor</label>
                <select class="apex-select" @bind="invoice.Party">
                    <option>GlobalTech Inc</option>
                    <option>Retail Corp</option>
                    <option>Startup Hub</option>
                    <option>ABC Supplies</option>
                    <option>XYZ Logistics</option>
                </select>
            </div>
            <div class="form-group">
                <label>Notes</label>
                <textarea class="apex-input" rows="3" @bind="invoice.Notes"></textarea>
            </div>
        </div>
    </div>

    <div class="form-panel">
        <div class="panel-header">
            Line Items
            <button class="btn-sm float-right" @onclick="AddLine">+ Add Line</button>
        </div>
        <table class="apex-table">
            <thead><tr><th>Description</th><th>Qty</th><th>Unit Price</th><th>Total</th><th></th></tr></thead>
            <tbody>
                @foreach (var line in invoice.Lines)
                {
                    <tr>
                        <td><input class="apex-input" style="margin:0" @bind="line.Description" /></td>
                        <td><input class="apex-input" style="margin:0;width:70px" type="number" @bind="line.Qty" @bind:after="Recalculate" /></td>
                        <td><input class="apex-input" style="margin:0;width:100px" type="number" @bind="line.UnitPrice" @bind:after="Recalculate" /></td>
                        <td>@((line.Qty * line.UnitPrice).ToString("C"))</td>
                        <td><button class="btn-sm" @onclick="() => RemoveLine(line)">&#10005;</button></td>
                    </tr>
                }
            </tbody>
        </table>

        <div class="invoice-totals">
            <div class="total-row"><span>Subtotal</span><span>@invoice.Subtotal.ToString("C")</span></div>
            <div class="total-row"><span>Tax (15%)</span><span>@invoice.Tax.ToString("C")</span></div>
            <div class="total-row total-grand"><span>Total</span><span>@invoice.Total.ToString("C")</span></div>
        </div>
    </div>
</div>

@if (saved) { <div class="alert-success">&#10003; Invoice saved successfully.</div> }

@code {
    [Parameter] public string? Id { get; set; }
    [Inject] NavigationManager Nav { get; set; } = default!;

    private bool IsNew => string.IsNullOrEmpty(Id);
    private bool saved = false;

    private InvoiceModel invoice = new()
    {
        Number = "INV-0001",
        Date = DateTime.Today,
        DueDate = DateTime.Today.AddDays(30),
        Currency = "USD",
        Party = "GlobalTech Inc",
        Lines = new()
        {
            new() { Description = "Consulting Services - January", Qty = 10, UnitPrice = 850 },
            new() { Description = "Software License (Annual)", Qty = 1, UnitPrice = 4200 },
            new() { Description = "Support & Maintenance", Qty = 1, UnitPrice = 1200 },
        }
    };

    private void AddLine() => invoice.Lines.Add(new());
    private void RemoveLine(LineItem l) { invoice.Lines.Remove(l); Recalculate(); }
    private void Recalculate() { invoice.Subtotal = invoice.Lines.Sum(l => l.Qty * l.UnitPrice); invoice.Tax = invoice.Subtotal * 0.15m; invoice.Total = invoice.Subtotal + invoice.Tax; }
    private void Save() { Recalculate(); saved = true; }
    private void Cancel() => Nav.NavigateTo("/finance/accounts-receivable");

    protected override void OnInitialized() => Recalculate();

    private class InvoiceModel
    {
        public string Number { get; set; } = "";
        public DateTime Date { get; set; }
        public DateTime DueDate { get; set; }
        public string Currency { get; set; } = "USD";
        public string Party { get; set; } = "";
        public string Notes { get; set; } = "";
        public List<LineItem> Lines { get; set; } = new();
        public decimal Subtotal { get; set; }
        public decimal Tax { get; set; }
        public decimal Total { get; set; }
    }
    private class LineItem { public string Description { get; set; } = ""; public decimal Qty { get; set; } = 1; public decimal UnitPrice { get; set; } = 0; }
}
'@

# ── FINANCE: Analytics Dashboard ──────────────────────────────────────────────
Write-Host "`n[Finance - Analytics]" -ForegroundColor Yellow
Write-File "$root\Modules\Finance\Analytics.razor" @'
@page "/finance/analytics"
@attribute [Authorize]
<PageTitle>Finance Analytics - ApexERP</PageTitle>

<div class="apex-page-header">
    <h1>&#128200; Finance Analytics</h1>
    <select class="apex-select" style="width:auto" @bind="period">
        <option>This Month</option><option>Last Quarter</option><option>YTD</option><option>Last Year</option>
    </select>
</div>

<div class="kpi-grid">
    <div class="kpi-card kpi-finance"><div class="kpi-icon">&#128200;</div><div class="kpi-body"><span class="kpi-label">Revenue</span><span class="kpi-value">$4,820,300</span><span class="kpi-delta positive">&#9650; 12.4%</span></div></div>
    <div class="kpi-card kpi-hr"><div class="kpi-icon">&#128179;</div><div class="kpi-body"><span class="kpi-label">Expenses</span><span class="kpi-value">$3,204,100</span><span class="kpi-delta negative">&#9650; 8.1%</span></div></div>
    <div class="kpi-card kpi-inventory"><div class="kpi-icon">&#128181;</div><div class="kpi-body"><span class="kpi-label">Net Profit</span><span class="kpi-value">$1,616,200</span><span class="kpi-delta positive">&#9650; 22.3%</span></div></div>
    <div class="kpi-card kpi-crm"><div class="kpi-icon">&#128182;</div><div class="kpi-body"><span class="kpi-label">Cash Flow</span><span class="kpi-value">$980,400</span><span class="kpi-delta positive">&#9650; 5.2%</span></div></div>
</div>

<div class="dashboard-grid">
    <div class="dash-panel">
        <div class="panel-header">Monthly Revenue vs Expenses</div>
        <div class="chart-area">
            @foreach (var m in months)
            {
                <div class="bar-group">
                    <div class="bar-label">@m.Name</div>
                    <div class="bar-track">
                        <div class="bar bar-revenue" style="width:@(m.Revenue/6000)%">@m.Revenue.ToString("C0")</div>
                    </div>
                    <div class="bar-track">
                        <div class="bar bar-expense" style="width:@(m.Expense/6000)%">@m.Expense.ToString("C0")</div>
                    </div>
                </div>
            }
            <div class="chart-legend">
                <span class="legend-dot" style="background:#1a56db"></span> Revenue
                <span class="legend-dot" style="background:#dc2626"></span> Expenses
            </div>
        </div>
    </div>

    <div class="dash-panel">
        <div class="panel-header">Expense Breakdown</div>
        <div class="donut-chart-area">
            @foreach (var cat in expenseCategories)
            {
                <div class="expense-row">
                    <span class="expense-label">@cat.Name</span>
                    <div class="expense-bar-track">
                        <div class="expense-bar" style="width:@cat.Pct%;background:@cat.Color"></div>
                    </div>
                    <span class="expense-pct">@cat.Pct%</span>
                    <span class="expense-amt">@cat.Amount.ToString("C0")</span>
                </div>
            }
        </div>
    </div>
</div>

<div class="dash-panel" style="margin-top:16px">
    <div class="panel-header">Top Customers by Revenue</div>
    <table class="apex-table">
        <thead><tr><th>Customer</th><th>Industry</th><th>Revenue YTD</th><th>Invoices</th><th>Avg Payment Days</th><th>Status</th></tr></thead>
        <tbody>
            <tr><td>GlobalTech Inc</td><td>Technology</td><td>$840,000</td><td>24</td><td>28</td><td><span class="badge badge-success">Excellent</span></td></tr>
            <tr><td>Retail Corp</td><td>Retail</td><td>$620,000</td><td>18</td><td>35</td><td><span class="badge badge-success">Good</span></td></tr>
            <tr><td>BuildRight Co</td><td>Construction</td><td>$480,000</td><td>12</td><td>42</td><td><span class="badge badge-warning">Average</span></td></tr>
            <tr><td>Startup Hub</td><td>Tech Startup</td><td>$240,000</td><td>8</td><td>55</td><td><span class="badge badge-danger">Slow Payer</span></td></tr>
            <tr><td>MedCare Group</td><td>Healthcare</td><td>$180,000</td><td>6</td><td>22</td><td><span class="badge badge-success">Excellent</span></td></tr>
        </tbody>
    </table>
</div>

@code {
    private string period = "This Month";

    private List<MonthData> months = new()
    {
        new("Jul", 380000, 280000), new("Aug", 420000, 310000), new("Sep", 390000, 295000),
        new("Oct", 450000, 320000), new("Nov", 480000, 340000), new("Dec", 520000, 360000),
    };

    private List<ExpCat> expenseCategories = new()
    {
        new("Salaries & Wages", 45, "#1a56db", 1441845),
        new("Operations", 22, "#0891b2", 704902),
        new("Marketing", 12, "#16a34a", 384492),
        new("IT & Software", 10, "#d97706", 320410),
        new("Facilities", 7, "#7c3aed", 224287),
        new("Other", 4, "#64748b", 128164),
    };

    private record MonthData(string Name, decimal Revenue, decimal Expense);
    private record ExpCat(string Name, int Pct, string Color, decimal Amount);
}
'@

# ── FINANCE: Approval Workflow ─────────────────────────────────────────────────
Write-Host "`n[Finance - Approvals]" -ForegroundColor Yellow
Write-File "$root\Modules\Finance\Approvals.razor" @'
@page "/finance/approvals"
@attribute [Authorize]
<PageTitle>Finance Approvals - ApexERP</PageTitle>

<div class="apex-page-header">
    <h1>&#9989; Finance Approvals</h1>
    <div class="tab-bar">
        <button class="tab @(tab=="pending"?"tab-active":"")" @onclick='()=>tab="pending"'>Pending (@pending.Count)</button>
        <button class="tab @(tab=="approved"?"tab-active":"")" @onclick='()=>tab="approved"'>Approved</button>
        <button class="tab @(tab=="rejected"?"tab-active":"")" @onclick='()=>tab="rejected"'>Rejected</button>
    </div>
</div>

@if (tab == "pending")
{
    @foreach (var item in pending)
    {
        <div class="approval-card">
            <div class="approval-header">
                <div>
                    <span class="approval-type">@item.Type</span>
                    <span class="approval-ref">@item.Reference</span>
                </div>
                <span class="approval-amount">@item.Amount.ToString("C")</span>
            </div>
            <div class="approval-body">
                <div class="approval-meta">
                    <span>&#128100; @item.RequestedBy</span>
                    <span>&#128197; @item.Date.ToString("MMM dd, yyyy")</span>
                    <span>&#127970; @item.Department</span>
                </div>
                <p class="approval-desc">@item.Description</p>
            </div>
            <div class="approval-footer">
                <div class="approval-workflow">
                    @foreach (var step in item.Steps)
                    {
                        <div class="workflow-step @step.Status">
                            <div class="step-dot"></div>
                            <div class="step-info">
                                <span class="step-role">@step.Role</span>
                                <span class="step-name">@step.Name</span>
                            </div>
                        </div>
                    }
                </div>
                <div class="approval-actions">
                    <button class="btn-secondary" @onclick="() => Reject(item)">&#10005; Reject</button>
                    <button class="btn-primary" @onclick="() => Approve(item)">&#10003; Approve</button>
                </div>
            </div>
        </div>
    }
}

@if (tab == "approved")
{
    <table class="apex-table">
        <thead><tr><th>Reference</th><th>Type</th><th>Amount</th><th>Requested By</th><th>Approved By</th><th>Date</th></tr></thead>
        <tbody>
            @foreach (var item in approved)
            {
                <tr>
                    <td>@item.Reference</td><td>@item.Type</td><td>@item.Amount.ToString("C")</td>
                    <td>@item.RequestedBy</td><td>Finance Manager</td><td>@item.Date.ToString("MMM dd")</td>
                </tr>
            }
        </tbody>
    </table>
}

@if (tab == "rejected")
{
    <table class="apex-table">
        <thead><tr><th>Reference</th><th>Type</th><th>Amount</th><th>Requested By</th><th>Reason</th><th>Date</th></tr></thead>
        <tbody>
            @foreach (var item in rejected)
            {
                <tr>
                    <td>@item.Reference</td><td>@item.Type</td><td>@item.Amount.ToString("C")</td>
                    <td>@item.RequestedBy</td><td>Budget exceeded</td><td>@item.Date.ToString("MMM dd")</td>
                </tr>
            }
        </tbody>
    </table>
}

@code {
    private string tab = "pending";

    private void Approve(ApprovalItem item) { item.Steps.Last().Status = "complete"; approved.Add(item); pending.Remove(item); }
    private void Reject(ApprovalItem item) { rejected.Add(item); pending.Remove(item); }

    private List<ApprovalItem> approved = new()
    {
        new() { Reference="PO-2088", Type="Purchase Order", Amount=4200, RequestedBy="Carol Dube", Department="Operations", Date=DateTime.Now.AddDays(-3), Description="Office supplies restock for Q1 2025." },
        new() { Reference="EXP-044", Type="Expense Claim", Amount=1840, RequestedBy="Brian Chikwanda", Department="IT", Date=DateTime.Now.AddDays(-5), Description="Conference attendance and travel expenses." },
    };

    private List<ApprovalItem> rejected = new()
    {
        new() { Reference="PO-2085", Type="Purchase Order", Amount=85000, RequestedBy="David Ncube", Department="Operations", Date=DateTime.Now.AddDays(-7), Description="Heavy machinery procurement." },
    };

    private List<ApprovalItem> pending = new()
    {
        new()
        {
            Reference = "PO-2091", Type = "Purchase Order", Amount = 33000,
            RequestedBy = "David Ncube", Department = "Operations", Date = DateTime.Now.AddDays(-1),
            Description = "Network infrastructure upgrade - 10 switches, 2 servers, cabling for new wing.",
            Steps = new() {
                new() { Role="Department Head", Name="Carol Dube", Status="complete" },
                new() { Role="Finance Manager", Name="Alice Moyo", Status="current" },
                new() { Role="CEO", Name="John Apex", Status="pending" },
            }
        },
        new()
        {
            Reference = "EXP-048", Type = "Expense Claim", Amount = 4800,
            RequestedBy = "Sarah Moyo", Department = "Marketing", Date = DateTime.Now,
            Description = "Trade show booth rental and marketing materials for ExpoZim 2025.",
            Steps = new() {
                new() { Role="Department Head", Name="Mike Sales", Status="complete" },
                new() { Role="Finance Manager", Name="Alice Moyo", Status="current" },
            }
        },
        new()
        {
            Reference = "BUDGET-012", Type = "Budget Amendment", Amount = 120000,
            RequestedBy = "Alice Moyo", Department = "Finance", Date = DateTime.Now.AddDays(-2),
            Description = "Supplementary budget allocation for IT infrastructure modernisation project.",
            Steps = new() {
                new() { Role="CFO", Name="Alice Moyo", Status="complete" },
                new() { Role="CEO", Name="John Apex", Status="current" },
                new() { Role="Board", Name="Board of Directors", Status="pending" },
            }
        },
    };

    private class ApprovalItem
    {
        public string Reference { get; set; } = "";
        public string Type { get; set; } = "";
        public decimal Amount { get; set; }
        public string RequestedBy { get; set; } = "";
        public string Department { get; set; } = "";
        public DateTime Date { get; set; }
        public string Description { get; set; } = "";
        public List<WorkflowStep> Steps { get; set; } = new() { new() { Role = "Manager", Name = "Pending", Status = "current" } };
    }
    private class WorkflowStep { public string Role { get; set; } = ""; public string Name { get; set; } = ""; public string Status { get; set; } = "pending"; }
}
'@

# ── HR: Employee Profile ───────────────────────────────────────────────────────
Write-Host "`n[HR - Employee Profile]" -ForegroundColor Yellow
Write-File "$root\Modules\HR\EmployeeProfile.razor" @'
@page "/hr/employees/{Id}"
@attribute [Authorize]
<PageTitle>Employee Profile - ApexERP</PageTitle>

<div class="apex-page-header">
    <h1>&#128100; Employee Profile</h1>
    <div style="display:flex;gap:8px">
        <button class="btn-secondary" @onclick='() => Nav.NavigateTo("/hr/employees")'>&#8592; Back</button>
        <button class="btn-primary" @onclick="Save">Save Changes</button>
    </div>
</div>

<div class="profile-grid">
    <div class="profile-card">
        <div class="profile-avatar">@emp.Name[0]</div>
        <h2>@emp.Name</h2>
        <span class="badge badge-success">@emp.Status</span>
        <div class="profile-meta">
            <div><span>&#128188;</span> @emp.Role</div>
            <div><span>&#127970;</span> @emp.Department</div>
            <div><span>&#128197;</span> Started @emp.StartDate.ToString("MMM yyyy")</div>
            <div><span>&#128222;</span> @emp.Phone</div>
            <div><span>&#128140;</span> @emp.Email</div>
        </div>
    </div>

    <div style="display:flex;flex-direction:column;gap:16px;flex:1">
        <div class="form-panel">
            <div class="panel-header">Personal Information</div>
            <div class="form-body">
                <div class="form-row">
                    <div class="form-group"><label>Full Name</label><input class="apex-input" @bind="emp.Name" /></div>
                    <div class="form-group"><label>ID Number</label><input class="apex-input" @bind="emp.IdNumber" /></div>
                </div>
                <div class="form-row">
                    <div class="form-group"><label>Email</label><input class="apex-input" type="email" @bind="emp.Email" /></div>
                    <div class="form-group"><label>Phone</label><input class="apex-input" @bind="emp.Phone" /></div>
                </div>
                <div class="form-row">
                    <div class="form-group"><label>Department</label>
                        <select class="apex-select" @bind="emp.Department">
                            <option>Finance</option><option>HR</option><option>IT</option><option>Operations</option><option>Marketing</option>
                        </select>
                    </div>
                    <div class="form-group"><label>Role / Title</label><input class="apex-input" @bind="emp.Role" /></div>
                </div>
                <div class="form-row">
                    <div class="form-group"><label>Start Date</label><input class="apex-input" type="date" @bind="emp.StartDate" /></div>
                    <div class="form-group"><label>Employment Type</label>
                        <select class="apex-select" @bind="emp.EmploymentType">
                            <option>Full-Time</option><option>Part-Time</option><option>Contract</option><option>Intern</option>
                        </select>
                    </div>
                </div>
            </div>
        </div>

        <div class="form-panel">
            <div class="panel-header">Compensation</div>
            <div class="form-body">
                <div class="form-row">
                    <div class="form-group"><label>Gross Salary</label><input class="apex-input" type="number" @bind="emp.Salary" /></div>
                    <div class="form-group"><label>Pay Frequency</label>
                        <select class="apex-select" @bind="emp.PayFrequency">
                            <option>Monthly</option><option>Bi-Weekly</option><option>Weekly</option>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group"><label>Bank Name</label><input class="apex-input" @bind="emp.BankName" /></div>
                    <div class="form-group"><label>Account Number</label><input class="apex-input" @bind="emp.BankAccount" /></div>
                </div>
            </div>
        </div>

        <div class="form-panel">
            <div class="panel-header">Performance Summary</div>
            <table class="apex-table">
                <thead><tr><th>Period</th><th>Rating</th><th>Reviewer</th><th>Notes</th></tr></thead>
                <tbody>
                    <tr><td>Q4 2024</td><td>&#11088;&#11088;&#11088;&#11088;&#11088; 5.0</td><td>CEO</td><td>Exceptional leadership during ERP rollout</td></tr>
                    <tr><td>Q3 2024</td><td>&#11088;&#11088;&#11088;&#11088; 4.5</td><td>CEO</td><td>Strong financial reporting improvements</td></tr>
                    <tr><td>Q2 2024</td><td>&#11088;&#11088;&#11088;&#11088; 4.2</td><td>Board</td><td>Good performance, on track with targets</td></tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

@if (saved) { <div class="alert-success" style="margin-top:16px">&#10003; Profile saved.</div> }

@code {
    [Parameter] public string? Id { get; set; }
    [Inject] NavigationManager Nav { get; set; } = default!;
    private bool saved = false;

    private EmployeeModel emp = new()
    {
        Name = "Alice Moyo", IdNumber = "63-121456A21", Email = "alice.moyo@apexerp.local",
        Phone = "+263 77 123 4567", Department = "Finance", Role = "CFO",
        StartDate = new DateTime(2020, 3, 1), EmploymentType = "Full-Time",
        Salary = 8500, PayFrequency = "Monthly", BankName = "First Capital Bank",
        BankAccount = "****4521", Status = "Active"
    };

    private void Save() { saved = true; }

    private class EmployeeModel
    {
        public string Name { get; set; } = ""; public string IdNumber { get; set; } = "";
        public string Email { get; set; } = ""; public string Phone { get; set; } = "";
        public string Department { get; set; } = ""; public string Role { get; set; } = "";
        public DateTime StartDate { get; set; } public string EmploymentType { get; set; } = "";
        public decimal Salary { get; set; } public string PayFrequency { get; set; } = "";
        public string BankName { get; set; } = ""; public string BankAccount { get; set; } = "";
        public string Status { get; set; } = "Active";
    }
}
'@

# ── HR: Leave Requests ─────────────────────────────────────────────────────────
Write-Host "`n[HR - Leave Requests]" -ForegroundColor Yellow
Write-File "$root\Modules\HR\LeaveRequests.razor" @'
@page "/hr/leave"
@attribute [Authorize]
<PageTitle>Leave Requests - ApexERP</PageTitle>

<div class="apex-page-header">
    <h1>&#127958; Leave Management</h1>
    <button class="btn-primary" @onclick="() => showForm = true">+ Request Leave</button>
</div>

<div class="summary-row">
    <div class="summary-card"><span>Annual Leave Remaining</span><strong>14 days</strong></div>
    <div class="summary-card"><span>Sick Leave Remaining</span><strong>8 days</strong></div>
    <div class="summary-card"><span>Pending Requests</span><strong class="text-negative">@requests.Count(r => r.Status == "Pending")</strong></div>
    <div class="summary-card"><span>Approved This Year</span><strong>18 days</strong></div>
</div>

<table class="apex-table">
    <thead><tr><th>Employee</th><th>Type</th><th>From</th><th>To</th><th>Days</th><th>Reason</th><th>Status</th><th>Action</th></tr></thead>
    <tbody>
        @foreach (var r in requests)
        {
            <tr>
                <td>@r.Employee</td><td>@r.Type</td>
                <td>@r.From.ToString("MMM dd")</td><td>@r.To.ToString("MMM dd")</td>
                <td>@((r.To - r.From).Days + 1)</td>
                <td>@r.Reason</td>
                <td><span class="badge @BadgeClass(r.Status)">@r.Status</span></td>
                <td>
                    @if (r.Status == "Pending")
                    {
                        <button class="btn-sm" style="color:green" @onclick="() => r.Status = `Approved`">&#10003;</button>
                        <button class="btn-sm" style="color:red" @onclick="() => r.Status = `Rejected`">&#10005;</button>
                    }
                </td>
            </tr>
        }
    </tbody>
</table>

@if (showForm)
{
    <div class="apex-modal-backdrop" @onclick="() => showForm = false">
        <div class="apex-modal" @onclick:stopPropagation>
            <div class="modal-header">New Leave Request</div>
            <div class="modal-body">
                <label>Employee</label>
                <select class="apex-select" @bind="newReq.Employee">
                    <option>Alice Moyo</option><option>Brian Chikwanda</option><option>Carol Dube</option><option>David Ncube</option>
                </select>
                <label>Leave Type</label>
                <select class="apex-select" @bind="newReq.Type">
                    <option>Annual Leave</option><option>Sick Leave</option><option>Maternity Leave</option><option>Paternity Leave</option><option>Unpaid Leave</option>
                </select>
                <label>From Date</label>
                <input class="apex-input" type="date" @bind="newReq.From" />
                <label>To Date</label>
                <input class="apex-input" type="date" @bind="newReq.To" />
                <label>Reason</label>
                <textarea class="apex-input" rows="2" @bind="newReq.Reason"></textarea>
            </div>
            <div class="modal-footer">
                <button class="btn-primary" @onclick="Submit">Submit</button>
                <button class="btn-secondary" @onclick="() => showForm = false">Cancel</button>
            </div>
        </div>
    </div>
}

@code {
    private bool showForm = false;
    private LeaveRequest newReq = new();

    private string BadgeClass(string s) => s switch { "Approved" => "badge-success", "Rejected" => "badge-danger", _ => "badge-warning" };

    private void Submit() { newReq.Status = "Pending"; requests.Add(newReq); newReq = new(); showForm = false; }

    private List<LeaveRequest> requests = new()
    {
        new() { Employee="Brian Chikwanda", Type="Annual Leave", From=DateTime.Now.AddDays(5), To=DateTime.Now.AddDays(10), Reason="Family vacation", Status="Pending" },
        new() { Employee="Carol Dube", Type="Sick Leave", From=DateTime.Now.AddDays(-3), To=DateTime.Now.AddDays(-1), Reason="Medical appointment", Status="Approved" },
        new() { Employee="David Ncube", Type="Annual Leave", From=DateTime.Now.AddDays(14), To=DateTime.Now.AddDays(21), Reason="Annual holiday", Status="Pending" },
        new() { Employee="Eva Mutasa", Type="Maternity Leave", From=DateTime.Now.AddDays(-30), To=DateTime.Now.AddDays(60), Reason="Maternity", Status="Approved" },
    };

    private class LeaveRequest { public string Employee{get;set;}=""; public string Type{get;set;}="Annual Leave"; public DateTime From{get;set;}=DateTime.Today; public DateTime To{get;set;}=DateTime.Today.AddDays(1); public string Reason{get;set;}=""; public string Status{get;set;}="Pending"; }
}
'@

# ── SUPPLY CHAIN: PO Detail / Approval ────────────────────────────────────────
Write-Host "`n[Supply Chain - PO Approval Workflow]" -ForegroundColor Yellow
Write-File "$root\Modules\SupplyChain\POApproval.razor" @'
@page "/supply/po-approval"
@attribute [Authorize]
<PageTitle>PO Approvals - ApexERP</PageTitle>

<div class="apex-page-header">
    <h1>&#128203; Purchase Order Approvals</h1>
</div>

@foreach (var po in orders)
{
    <div class="approval-card">
        <div class="approval-header">
            <div>
                <span class="approval-type">Purchase Order</span>
                <span class="approval-ref">@po.Number</span>
            </div>
            <span class="approval-amount">@po.Total.ToString("C")</span>
        </div>
        <div class="approval-body">
            <div class="approval-meta">
                <span>&#128666; @po.Vendor</span>
                <span>&#128197; @po.Date.ToString("MMM dd, yyyy")</span>
                <span>&#128100; @po.RequestedBy</span>
            </div>
            <table class="apex-table" style="margin-top:10px">
                <thead><tr><th>Item</th><th>Qty</th><th>Unit Price</th><th>Total</th></tr></thead>
                <tbody>
                    @foreach (var item in po.Items)
                    {
                        <tr><td>@item.Name</td><td>@item.Qty</td><td>@item.Price.ToString("C")</td><td>@((item.Qty * item.Price).ToString("C"))</td></tr>
                    }
                </tbody>
            </table>
        </div>
        <div class="approval-footer">
            <div class="approval-workflow">
                @foreach (var step in po.Steps)
                {
                    <div class="workflow-step @step.Status">
                        <div class="step-dot"></div>
                        <div class="step-info"><span class="step-role">@step.Role</span><span class="step-name">@step.Name</span></div>
                    </div>
                }
            </div>
            @if (po.Status == "Pending")
            {
                <div class="approval-actions">
                    <button class="btn-secondary" @onclick="() => po.Status = `Rejected`">&#10005; Reject</button>
                    <button class="btn-primary" @onclick="() => { po.Status = `Approved`; po.Steps.FirstOrDefault(s => s.Status == `current`).Status = `complete`; }">&#10003; Approve</button>
                </div>
            }
            else
            {
                <span class="badge @(po.Status == "Approved" ? "badge-success" : "badge-danger")">@po.Status</span>
            }
        </div>
    </div>
}

@code {
    private List<POModel> orders = new()
    {
        new()
        {
            Number="PO-2091", Vendor="Tech Vendors Ltd", Date=DateTime.Now.AddDays(-1),
            RequestedBy="David Ncube", Status="Pending", Total=33000,
            Items=new(){ new("24-Port Network Switch",4,1800), new("Dell PowerEdge Server",2,8000), new("Cat6 Cabling (500m)",3,1400) },
            Steps=new(){ new("Dept Head","Carol Dube","complete"), new("Finance","Alice Moyo","current"), new("CEO","John Apex","pending") }
        },
        new()
        {
            Number="PO-2092", Vendor="ABC Supplies", Date=DateTime.Now,
            RequestedBy="Carol Dube", Status="Pending", Total=4200,
            Items=new(){ new("Office Paper A4 (Box)",20,45), new("Printer Toner HP",5,180), new("Desk Organizers",30,40) },
            Steps=new(){ new("Dept Head","Carol Dube","complete"), new("Finance","Alice Moyo","current") }
        },
    };

    private class POModel
    {
        public string Number{get;set;}=""; public string Vendor{get;set;}=""; public DateTime Date{get;set;}
        public string RequestedBy{get;set;}=""; public string Status{get;set;}=""; public decimal Total{get;set;}
        public List<POItem> Items{get;set;}=new(); public List<WorkflowStep> Steps{get;set;}=new();
    }
    private class POItem { public string Name{get;set;}=""; public int Qty{get;set;} public decimal Price{get;set;}
        public POItem(string n, int q, decimal p){Name=n;Qty=q;Price=p;} }
    private class WorkflowStep { public string Role{get;set;}=""; public string Name{get;set;}=""; public string Status{get;set;}="pending";
        public WorkflowStep(string r, string n, string s){Role=r;Name=n;Status=s;} }
}
'@

# ── INVENTORY: Stock Detail & Adjustment ──────────────────────────────────────
Write-Host "`n[Inventory - Stock Adjustment]" -ForegroundColor Yellow
Write-File "$root\Modules\Inventory\StockAdjustment.razor" @'
@page "/inventory/adjustment"
@attribute [Authorize]
<PageTitle>Stock Adjustment - ApexERP</PageTitle>

<div class="apex-page-header">
    <h1>&#128221; Stock Adjustments</h1>
    <button class="btn-primary" @onclick="() => showForm = true">+ New Adjustment</button>
</div>

<table class="apex-table">
    <thead><tr><th>Date</th><th>SKU</th><th>Item</th><th>Type</th><th>Qty Change</th><th>Reason</th><th>Done By</th><th>Status</th></tr></thead>
    <tbody>
        @foreach (var adj in adjustments)
        {
            <tr>
                <td>@adj.Date.ToString("yyyy-MM-dd")</td>
                <td>@adj.SKU</td><td>@adj.Item</td>
                <td><span class="badge @(adj.Type=="Add"?"badge-success":"badge-danger")">@adj.Type</span></td>
                <td class="@(adj.Type=="Add"?"text-positive":"text-negative")">@(adj.Type=="Add"?"+":"-")@adj.Qty</td>
                <td>@adj.Reason</td><td>@adj.DoneBy</td>
                <td><span class="badge badge-success">Completed</span></td>
            </tr>
        }
    </tbody>
</table>

@if (showForm)
{
    <div class="apex-modal-backdrop" @onclick="() => showForm = false">
        <div class="apex-modal" @onclick:stopPropagation>
            <div class="modal-header">New Stock Adjustment</div>
            <div class="modal-body">
                <label>SKU / Item</label>
                <select class="apex-select" @bind="newAdj.SKU">
                    <option>SKU001 - Laptop Dell XPS</option>
                    <option>SKU002 - Office Chair</option>
                    <option>SKU003 - Steel Rods 10mm</option>
                    <option>SKU004 - Printer Paper A4</option>
                </select>
                <label>Adjustment Type</label>
                <select class="apex-select" @bind="newAdj.Type">
                    <option>Add</option><option>Remove</option>
                </select>
                <label>Quantity</label>
                <input class="apex-input" type="number" @bind="newAdj.Qty" />
                <label>Reason</label>
                <select class="apex-select" @bind="newAdj.Reason">
                    <option>Received from supplier</option>
                    <option>Damaged goods</option>
                    <option>Stock count correction</option>
                    <option>Internal transfer</option>
                    <option>Write-off</option>
                </select>
            </div>
            <div class="modal-footer">
                <button class="btn-primary" @onclick="Save">Save</button>
                <button class="btn-secondary" @onclick="() => showForm = false">Cancel</button>
            </div>
        </div>
    </div>
}

@code {
    private bool showForm = false;
    private Adjustment newAdj = new();

    private void Save()
    {
        newAdj.Date = DateTime.Now;
        newAdj.Item = newAdj.SKU.Split(" - ").Last();
        newAdj.SKU = newAdj.SKU.Split(" - ").First();
        newAdj.DoneBy = "Dev User";
        adjustments.Insert(0, newAdj);
        newAdj = new();
        showForm = false;
    }

    private List<Adjustment> adjustments = new()
    {
        new(){Date=DateTime.Now.AddDays(-1),SKU="SKU003",Item="Steel Rods 10mm",Type="Add",Qty=500,Reason="Received from supplier",DoneBy="David Ncube"},
        new(){Date=DateTime.Now.AddDays(-2),SKU="SKU001",Item="Laptop Dell XPS",Type="Remove",Qty=2,Reason="Damaged goods",DoneBy="Brian Chikwanda"},
        new(){Date=DateTime.Now.AddDays(-3),SKU="SKU004",Item="Printer Paper A4",Type="Remove",Qty=40,Reason="Stock count correction",DoneBy="Carol Dube"},
        new(){Date=DateTime.Now.AddDays(-5),SKU="SKU002",Item="Office Chair",Type="Add",Qty=10,Reason="Received from supplier",DoneBy="David Ncube"},
    };

    private class Adjustment { public DateTime Date{get;set;} public string SKU{get;set;}=""; public string Item{get;set;}=""; public string Type{get;set;}="Add"; public int Qty{get;set;} public string Reason{get;set;}=""; public string DoneBy{get;set;}=""; }
}
'@

# ── INVENTORY: Analytics ───────────────────────────────────────────────────────
Write-File "$root\Modules\Inventory\InventoryAnalytics.razor" @'
@page "/inventory/analytics"
@attribute [Authorize]
<PageTitle>Inventory Analytics - ApexERP</PageTitle>

<div class="apex-page-header"><h1>&#128200; Inventory Analytics</h1></div>

<div class="kpi-grid">
    <div class="kpi-card kpi-finance"><div class="kpi-icon">&#128230;</div><div class="kpi-body"><span class="kpi-label">Total SKUs</span><span class="kpi-value">1,284</span><span class="kpi-delta positive">&#9650; 24 new</span></div></div>
    <div class="kpi-card kpi-hr"><div class="kpi-icon">&#128181;</div><div class="kpi-body"><span class="kpi-label">Stock Value</span><span class="kpi-value">$2.4M</span><span class="kpi-delta positive">&#9650; 4.2%</span></div></div>
    <div class="kpi-card kpi-inventory"><div class="kpi-icon">&#9888;</div><div class="kpi-body"><span class="kpi-label">Low Stock Items</span><span class="kpi-value">47</span><span class="kpi-delta negative">&#9650; 12 critical</span></div></div>
    <div class="kpi-card kpi-crm"><div class="kpi-icon">&#128665;</div><div class="kpi-body"><span class="kpi-label">Turnover Rate</span><span class="kpi-value">4.2x</span><span class="kpi-delta positive">&#9650; Industry avg 3.1x</span></div></div>
</div>

<div class="dashboard-grid">
    <div class="dash-panel">
        <div class="panel-header">Stock by Category</div>
        <div class="donut-chart-area" style="padding:16px">
            @foreach (var cat in categories)
            {
                <div class="expense-row">
                    <span class="expense-label">@cat.Name</span>
                    <div class="expense-bar-track"><div class="expense-bar" style="width:@cat.Pct%;background:@cat.Color"></div></div>
                    <span class="expense-pct">@cat.Pct%</span>
                    <span class="expense-amt">@cat.Count items</span>
                </div>
            }
        </div>
    </div>
    <div class="dash-panel">
        <div class="panel-header">Low Stock Alerts</div>
        <table class="apex-table">
            <thead><tr><th>SKU</th><th>Item</th><th>Stock</th><th>Reorder</th></tr></thead>
            <tbody>
                <tr><td>SKU002</td><td>Office Chair</td><td class="text-negative">8</td><td>10</td></tr>
                <tr><td>SKU004</td><td>Printer Paper A4</td><td class="text-negative">120</td><td>200</td></tr>
                <tr><td>SKU008</td><td>Safety Helmets</td><td class="text-negative">5</td><td>20</td></tr>
                <tr><td>SKU012</td><td>Generator Fuel (L)</td><td class="text-negative">80</td><td>200</td></tr>
                <tr><td>SKU019</td><td>First Aid Kits</td><td class="text-negative">2</td><td>10</td></tr>
            </tbody>
        </table>
    </div>
</div>

@code {
    private List<(string Name, int Pct, string Color, int Count)> categories = new()
    {
        ("Electronics", 35, "#1a56db", 449), ("Raw Materials", 28, "#0891b2", 359),
        ("Office Supplies", 18, "#16a34a", 231), ("Consumables", 12, "#d97706", 154),
        ("Equipment", 7, "#7c3aed", 91),
    };
}
'@

# ── CRM: Lead Detail ───────────────────────────────────────────────────────────
Write-Host "`n[CRM - Lead Detail]" -ForegroundColor Yellow
Write-File "$root\Modules\CRM\LeadDetail.razor" @'
@page "/crm/leads/{Id}"
@attribute [Authorize]
<PageTitle>Lead Detail - ApexERP</PageTitle>

<div class="apex-page-header">
    <h1>&#127919; Lead Profile</h1>
    <div style="display:flex;gap:8px">
        <button class="btn-secondary" @onclick='() => Nav.NavigateTo("/crm/leads")'>&#8592; Back</button>
        <button class="btn-primary" @onclick="Save">Save</button>
    </div>
</div>

<div class="profile-grid">
    <div class="profile-card">
        <div class="profile-avatar" style="background:#1a56db">@lead.Name[0]</div>
        <h2>@lead.Name</h2>
        <p style="color:var(--apex-text-muted)">@lead.Company</p>
        <span class="badge badge-warning">@lead.Stage</span>
        <div class="profile-meta">
            <div><span>&#128140;</span> @lead.Email</div>
            <div><span>&#128222;</span> @lead.Phone</div>
            <div><span>&#127758;</span> @lead.Country</div>
            <div><span>&#128181;</span> @lead.Value.ToString("C")</div>
        </div>
        <div style="margin-top:16px">
            <label style="font-size:12px;font-weight:600;color:var(--apex-text-muted)">Pipeline Stage</label>
            <select class="apex-select" @bind="lead.Stage">
                <option>New</option><option>Qualified</option><option>Proposal</option><option>Negotiation</option><option>Closed Won</option><option>Closed Lost</option>
            </select>
        </div>
    </div>

    <div style="flex:1;display:flex;flex-direction:column;gap:16px">
        <div class="form-panel">
            <div class="panel-header">Lead Information</div>
            <div class="form-body">
                <div class="form-row">
                    <div class="form-group"><label>Full Name</label><input class="apex-input" @bind="lead.Name" /></div>
                    <div class="form-group"><label>Company</label><input class="apex-input" @bind="lead.Company" /></div>
                </div>
                <div class="form-row">
                    <div class="form-group"><label>Email</label><input class="apex-input" type="email" @bind="lead.Email" /></div>
                    <div class="form-group"><label>Phone</label><input class="apex-input" @bind="lead.Phone" /></div>
                </div>
                <div class="form-row">
                    <div class="form-group"><label>Deal Value</label><input class="apex-input" type="number" @bind="lead.Value" /></div>
                    <div class="form-group"><label>Source</label>
                        <select class="apex-select" @bind="lead.Source">
                            <option>Website</option><option>Referral</option><option>Cold Call</option><option>Trade Show</option><option>Social Media</option>
                        </select>
                    </div>
                </div>
                <div class="form-group"><label>Notes</label><textarea class="apex-input" rows="3" @bind="lead.Notes"></textarea></div>
            </div>
        </div>

        <div class="form-panel">
            <div class="panel-header">
                Activity Log
                <button class="btn-sm float-right" @onclick="AddActivity">+ Log Activity</button>
            </div>
            <div style="padding:12px;display:flex;flex-direction:column;gap:8px">
                @foreach (var act in lead.Activities)
                {
                    <div class="activity-item">
                        <div class="activity-icon">@act.Icon</div>
                        <div class="activity-body">
                            <span class="activity-title">@act.Title</span>
                            <span class="activity-date">@act.Date.ToString("MMM dd, yyyy HH:mm")</span>
                            <span class="activity-note">@act.Note</span>
                        </div>
                    </div>
                }
            </div>
        </div>
    </div>
</div>

@if (saved) { <div class="alert-success" style="margin-top:16px">&#10003; Lead updated.</div> }

@code {
    [Parameter] public string? Id { get; set; }
    [Inject] NavigationManager Nav { get; set; } = default!;
    private bool saved = false;
    private void Save() { saved = true; }

    private void AddActivity()
    {
        lead.Activities.Insert(0, new() { Icon = "&#128222;", Title = "Call logged", Note = "Followed up on proposal.", Date = DateTime.Now });
    }

    private LeadModel lead = new()
    {
        Name = "Sarah Johnson", Company = "Innovate Ltd", Email = "sarah@innovateltd.com",
        Phone = "+27 82 456 7890", Country = "South Africa", Value = 120000,
        Stage = "Proposal", Source = "Referral", Notes = "Very interested in the full ERP suite. Requested demo for their board next week.",
        Activities = new()
        {
            new() { Icon="&#128203;", Title="Proposal sent", Note="Sent full ERP proposal document via email.", Date=DateTime.Now.AddDays(-2) },
            new() { Icon="&#128222;", Title="Discovery call", Note="45 min call. Identified pain points in their current accounting system.", Date=DateTime.Now.AddDays(-7) },
            new() { Icon="&#128140;", Title="Initial contact", Note="Lead came through referral from GlobalTech Inc.", Date=DateTime.Now.AddDays(-14) },
        }
    };

    private class LeadModel
    {
        public string Name{get;set;}=""; public string Company{get;set;}=""; public string Email{get;set;}="";
        public string Phone{get;set;}=""; public string Country{get;set;}=""; public decimal Value{get;set;}
        public string Stage{get;set;}=""; public string Source{get;set;}=""; public string Notes{get;set;}="";
        public List<ActivityLog> Activities{get;set;}=new();
    }
    private class ActivityLog { public string Icon{get;set;}=""; public string Title{get;set;}=""; public string Note{get;set;}=""; public DateTime Date{get;set;}=DateTime.Now; }
}
'@

# ── CRM: Sales Pipeline ────────────────────────────────────────────────────────
Write-File "$root\Modules\CRM\Pipeline.razor" @'
@page "/crm/pipeline"
@attribute [Authorize]
<PageTitle>Sales Pipeline - ApexERP</PageTitle>

<div class="apex-page-header">
    <h1>&#128202; Sales Pipeline</h1>
    <span style="color:var(--apex-text-muted)">Total Pipeline: <strong>$1,840,000</strong></span>
</div>

<div class="pipeline-board">
    @foreach (var stage in stages)
    {
        <div class="pipeline-col">
            <div class="pipeline-header">
                <span>@stage.Name</span>
                <span class="pipeline-count">@stage.Leads.Count</span>
            </div>
            <div class="pipeline-total">@stage.Leads.Sum(l => l.Value).ToString("C0")</div>
            @foreach (var lead in stage.Leads)
            {
                <div class="pipeline-card">
                    <div class="pipeline-card-name">@lead.Name</div>
                    <div class="pipeline-card-company">@lead.Company</div>
                    <div class="pipeline-card-value">@lead.Value.ToString("C0")</div>
                    <div class="pipeline-card-meta">
                        <span>&#128197; @lead.CloseDate.ToString("MMM dd")</span>
                        <span>&#128100; @lead.Owner</span>
                    </div>
                </div>
            }
        </div>
    }
</div>

@code {
    private List<PipelineStage> stages = new()
    {
        new("New", new(){ new("John Smith","Acme Corp",45000,DateTime.Now.AddDays(30),"Team A"), new("Lisa Wong","DataSync Inc",15000,DateTime.Now.AddDays(14),"Team C") }),
        new("Qualified", new(){ new("Mark Peters","BuildRight Co",280000,DateTime.Now.AddDays(45),"Team A"), new("Anna Dube","MedCare",90000,DateTime.Now.AddDays(20),"Team B") }),
        new("Proposal", new(){ new("Sarah Johnson","Innovate Ltd",120000,DateTime.Now.AddDays(10),"Team B"), new("Chris Moyo","RetailMax",65000,DateTime.Now.AddDays(7),"Team A") }),
        new("Negotiation", new(){ new("Tom Banda","ConstructCo",380000,DateTime.Now.AddDays(5),"Team A") }),
        new("Closed Won", new(){ new("GlobalTech","GlobalTech Inc",480000,DateTime.Now.AddDays(-2),"Team B"), new("RetailCorp","Retail Corp",240000,DateTime.Now.AddDays(-5),"Team A") }),
    };

    private class PipelineStage { public string Name{get;set;}=""; public List<PipelineLead> Leads{get;set;}=new();
        public PipelineStage(string n, List<PipelineLead> l){Name=n;Leads=l;} }
    private class PipelineLead { public string Name{get;set;}=""; public string Company{get;set;}=""; public decimal Value{get;set;} public DateTime CloseDate{get;set;} public string Owner{get;set;}="";
        public PipelineLead(string n, string c, decimal v, DateTime d, string o){Name=n;Company=c;Value=v;CloseDate=d;Owner=o;} }
}
'@

# ── Update NavMenu with new pages ─────────────────────────────────────────────
Write-Host "`n[Updating NavMenu]" -ForegroundColor Yellow
Write-File "$root\Layout\NavMenu.razor" @'
@using Microsoft.AspNetCore.Components.Authorization
@using Microsoft.AspNetCore.Components.Routing

<nav class="apex-nav">
    <div class="nav-section">
        <span class="nav-label">CORE</span>
        <NavLink class="nav-item" href="/" Match="NavLinkMatch.All"><span class="nav-icon">&#128200;</span> Dashboard</NavLink>
    </div>
    <div class="nav-section">
        <span class="nav-label">FINANCE</span>
        <NavLink class="nav-item" href="/finance/ledger"><span class="nav-icon">&#128218;</span> General Ledger</NavLink>
        <NavLink class="nav-item" href="/finance/accounts-payable"><span class="nav-icon">&#128179;</span> Accounts Payable</NavLink>
        <NavLink class="nav-item" href="/finance/accounts-receivable"><span class="nav-icon">&#128180;</span> Accounts Receivable</NavLink>
        <NavLink class="nav-item" href="/finance/invoice/new"><span class="nav-icon">&#128196;</span> New Invoice</NavLink>
        <NavLink class="nav-item" href="/finance/budget"><span class="nav-icon">&#128202;</span> Budgeting</NavLink>
        <NavLink class="nav-item" href="/finance/approvals"><span class="nav-icon">&#9989;</span> Approvals</NavLink>
        <NavLink class="nav-item" href="/finance/analytics"><span class="nav-icon">&#128201;</span> Analytics</NavLink>
        <NavLink class="nav-item" href="/finance/reports"><span class="nav-icon">&#128196;</span> Reports</NavLink>
    </div>
    <div class="nav-section">
        <span class="nav-label">HUMAN RESOURCES</span>
        <NavLink class="nav-item" href="/hr/employees"><span class="nav-icon">&#128100;</span> Employees</NavLink>
        <NavLink class="nav-item" href="/hr/leave"><span class="nav-icon">&#127958;</span> Leave Requests</NavLink>
        <NavLink class="nav-item" href="/hr/payroll"><span class="nav-icon">&#128181;</span> Payroll</NavLink>
        <NavLink class="nav-item" href="/hr/performance"><span class="nav-icon">&#11088;</span> Performance</NavLink>
    </div>
    <div class="nav-section">
        <span class="nav-label">SUPPLY CHAIN</span>
        <NavLink class="nav-item" href="/supply/vendors"><span class="nav-icon">&#128666;</span> Vendors</NavLink>
        <NavLink class="nav-item" href="/supply/purchase-orders"><span class="nav-icon">&#128203;</span> Purchase Orders</NavLink>
        <NavLink class="nav-item" href="/supply/po-approval"><span class="nav-icon">&#9989;</span> PO Approvals</NavLink>
        <NavLink class="nav-item" href="/supply/contracts"><span class="nav-icon">&#128196;</span> Contracts</NavLink>
    </div>
    <div class="nav-section">
        <span class="nav-label">INVENTORY</span>
        <NavLink class="nav-item" href="/inventory/stock"><span class="nav-icon">&#128230;</span> Stock</NavLink>
        <NavLink class="nav-item" href="/inventory/adjustment"><span class="nav-icon">&#128221;</span> Adjustments</NavLink>
        <NavLink class="nav-item" href="/inventory/analytics"><span class="nav-icon">&#128200;</span> Analytics</NavLink>
        <NavLink class="nav-item" href="/inventory/warehouse"><span class="nav-icon">&#127970;</span> Warehouse</NavLink>
    </div>
    <div class="nav-section">
        <span class="nav-label">CRM</span>
        <NavLink class="nav-item" href="/crm/pipeline"><span class="nav-icon">&#128202;</span> Pipeline</NavLink>
        <NavLink class="nav-item" href="/crm/leads"><span class="nav-icon">&#127919;</span> Leads</NavLink>
        <NavLink class="nav-item" href="/crm/customers"><span class="nav-icon">&#128101;</span> Customers</NavLink>
    </div>
    <div class="nav-section">
        <span class="nav-label">SYSTEM</span>
        <NavLink class="nav-item" href="/admin/settings"><span class="nav-icon">&#9881;</span> Settings</NavLink>
    </div>
</nav>
'@

# ── Append new CSS ─────────────────────────────────────────────────────────────
Write-Host "`n[Adding new CSS]" -ForegroundColor Yellow
Add-Content "$root\wwwroot\css\apex-erp.css" @'

/* ── Forms ─────────────────────────────────────────────────────── */
.form-grid      { display:grid; grid-template-columns:1fr 1.4fr; gap:16px; align-items:start; }
.form-panel     { background:var(--apex-surface); border:1px solid var(--apex-border); border-radius:10px; overflow:hidden; }
.form-body      { padding:20px; display:flex; flex-direction:column; }
.form-row       { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
.form-group     { display:flex; flex-direction:column; }
.form-group label { font-size:12px; font-weight:600; color:var(--apex-text-muted); margin-bottom:4px; }

/* ── Invoice Totals ─────────────────────────────────────────────── */
.invoice-totals { padding:16px; border-top:1px solid var(--apex-border); display:flex; flex-direction:column; gap:6px; align-items:flex-end; }
.total-row      { display:flex; gap:40px; justify-content:flex-end; font-size:13px; }
.total-grand    { font-size:16px; font-weight:700; padding-top:6px; border-top:2px solid var(--apex-border); }

/* ── Approval Cards ─────────────────────────────────────────────── */
.approval-card  { background:var(--apex-surface); border:1px solid var(--apex-border); border-radius:10px; margin-bottom:16px; overflow:hidden; }
.approval-header{ display:flex; justify-content:space-between; align-items:center; padding:14px 20px; background:#f8fafc; border-bottom:1px solid var(--apex-border); }
.approval-type  { font-size:11px; font-weight:700; color:var(--apex-primary); text-transform:uppercase; letter-spacing:0.5px; margin-right:10px; }
.approval-ref   { font-size:14px; font-weight:700; }
.approval-amount{ font-size:20px; font-weight:700; color:var(--apex-primary); }
.approval-body  { padding:16px 20px; }
.approval-meta  { display:flex; gap:20px; font-size:13px; color:var(--apex-text-muted); margin-bottom:10px; }
.approval-desc  { font-size:13px; line-height:1.5; }
.approval-footer{ display:flex; justify-content:space-between; align-items:center; padding:14px 20px; border-top:1px solid var(--apex-border); }
.approval-actions{ display:flex; gap:8px; }

/* ── Workflow Steps ─────────────────────────────────────────────── */
.approval-workflow { display:flex; gap:0; align-items:center; }
.workflow-step  { display:flex; align-items:center; gap:8px; }
.workflow-step:not(:last-child)::after { content:''; display:block; width:40px; height:2px; background:var(--apex-border); margin:0 4px; }
.step-dot       { width:12px; height:12px; border-radius:50%; background:var(--apex-border); flex-shrink:0; }
.workflow-step.complete .step-dot { background:var(--apex-success); }
.workflow-step.current .step-dot  { background:var(--apex-primary); box-shadow:0 0 0 3px #dbeafe; }
.step-info      { display:flex; flex-direction:column; }
.step-role      { font-size:10px; color:var(--apex-text-muted); font-weight:600; }
.step-name      { font-size:12px; font-weight:600; }

/* ── Profile ────────────────────────────────────────────────────── */
.profile-grid   { display:grid; grid-template-columns:280px 1fr; gap:16px; align-items:start; }
.profile-card   { background:var(--apex-surface); border:1px solid var(--apex-border); border-radius:10px; padding:24px; display:flex; flex-direction:column; align-items:center; gap:10px; text-align:center; }
.profile-avatar { width:72px; height:72px; border-radius:50%; background:var(--apex-primary); color:#fff; font-size:28px; font-weight:700; display:flex; align-items:center; justify-content:center; }
.profile-meta   { display:flex; flex-direction:column; gap:8px; width:100%; text-align:left; margin-top:8px; }
.profile-meta div { display:flex; gap:8px; font-size:13px; align-items:center; color:var(--apex-text-muted); }

/* ── Charts ─────────────────────────────────────────────────────── */
.chart-area     { padding:16px; }
.bar-group      { margin-bottom:12px; }
.bar-label      { font-size:12px; font-weight:600; color:var(--apex-text-muted); margin-bottom:4px; }
.bar-track      { background:#f1f5f9; border-radius:4px; height:22px; margin-bottom:3px; overflow:hidden; }
.bar            { height:100%; border-radius:4px; display:flex; align-items:center; padding:0 8px; font-size:11px; color:#fff; font-weight:600; min-width:60px; transition:width 0.5s; }
.bar-revenue    { background:var(--apex-primary); }
.bar-expense    { background:#dc2626; }
.chart-legend   { display:flex; gap:16px; margin-top:12px; font-size:12px; }
.legend-dot     { display:inline-block; width:10px; height:10px; border-radius:50%; margin-right:4px; }
.donut-chart-area{ padding:16px; }
.expense-row    { display:grid; grid-template-columns:140px 1fr 40px 80px; align-items:center; gap:8px; margin-bottom:10px; }
.expense-label  { font-size:12px; font-weight:600; }
.expense-bar-track { background:#f1f5f9; border-radius:4px; height:10px; overflow:hidden; }
.expense-bar    { height:100%; border-radius:4px; }
.expense-pct    { font-size:12px; font-weight:700; text-align:right; }
.expense-amt    { font-size:12px; color:var(--apex-text-muted); text-align:right; }

/* ── Tabs ───────────────────────────────────────────────────────── */
.tab-bar        { display:flex; gap:4px; background:#f1f5f9; padding:4px; border-radius:8px; }
.tab            { padding:6px 16px; border:none; border-radius:6px; cursor:pointer; font-size:13px; font-weight:500; background:transparent; color:var(--apex-text-muted); }
.tab-active     { background:#fff; color:var(--apex-primary); font-weight:700; box-shadow:0 1px 3px rgba(0,0,0,0.1); }

/* ── Activity Log ───────────────────────────────────────────────── */
.activity-item  { display:flex; gap:12px; padding:10px 0; border-bottom:1px solid var(--apex-border); }
.activity-icon  { font-size:18px; flex-shrink:0; }
.activity-body  { display:flex; flex-direction:column; gap:2px; }
.activity-title { font-size:13px; font-weight:600; }
.activity-date  { font-size:11px; color:var(--apex-text-muted); }
.activity-note  { font-size:12px; color:var(--apex-text); }

/* ── Pipeline Board ─────────────────────────────────────────────── */
.pipeline-board { display:grid; grid-template-columns:repeat(5,1fr); gap:12px; overflow-x:auto; }
.pipeline-col   { background:#f8fafc; border-radius:10px; border:1px solid var(--apex-border); min-width:200px; }
.pipeline-header{ display:flex; justify-content:space-between; align-items:center; padding:12px 14px; font-weight:700; font-size:13px; border-bottom:1px solid var(--apex-border); }
.pipeline-count { background:var(--apex-primary); color:#fff; border-radius:20px; padding:2px 8px; font-size:11px; }
.pipeline-total { padding:6px 14px; font-size:12px; color:var(--apex-text-muted); font-weight:600; border-bottom:1px solid var(--apex-border); }
.pipeline-card  { background:#fff; border:1px solid var(--apex-border); border-radius:8px; margin:10px; padding:12px; cursor:pointer; transition:box-shadow 0.15s; }
.pipeline-card:hover { box-shadow:0 4px 12px rgba(0,0,0,0.1); }
.pipeline-card-name { font-size:13px; font-weight:700; }
.pipeline-card-company { font-size:12px; color:var(--apex-text-muted); }
.pipeline-card-value { font-size:15px; font-weight:700; color:var(--apex-primary); margin:6px 0; }
.pipeline-card-meta { display:flex; justify-content:space-between; font-size:11px; color:var(--apex-text-muted); }
'@

# ── Build ──────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Building..." -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

Remove-Item -Recurse -Force .\bin, .\obj -ErrorAction SilentlyContinue
dotnet build --nologo -v q 2>&1 | Write-Host

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "  BUILD SUCCEEDED" -ForegroundColor Green
    Write-Host "  Run: dotnet run" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  New pages added:" -ForegroundColor White
    Write-Host "    Finance:  Invoice Form, Approvals, Analytics" -ForegroundColor Gray
    Write-Host "    HR:       Employee Profile, Leave Requests" -ForegroundColor Gray
    Write-Host "    Supply:   PO Approval Workflow" -ForegroundColor Gray
    Write-Host "    Inventory:Stock Adjustments, Analytics" -ForegroundColor Gray
    Write-Host "    CRM:      Lead Detail, Sales Pipeline" -ForegroundColor Gray
} else {
    Write-Host "  BUILD FAILED - check errors above" -ForegroundColor Red
}