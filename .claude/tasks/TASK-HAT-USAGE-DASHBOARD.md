# Task: Implement Hat Usage Statistics Dashboard

**Task ID:** TASK-HAT-USAGE-DASHBOARD
**Priority:** Medium
**Estimated Effort:** 8-12 hours
**Status:** Pending
**Created:** 2025-10-11
**Assigned Hat:** `ui-designer` → `web-dev-master` → `senior-backend-engineer`

## 📋 Overview

Implement a comprehensive statistics dashboard in the admin panel to visualize orchestrator hat usage patterns. This will help track which expertise areas are most utilized, identify workload distribution, and provide insights into development patterns.

## 🎯 Objectives

1. Create API endpoints to serve hat usage statistics
2. Design intuitive dashboard UI for hat usage visualization
3. Implement real-time updates of statistics
4. Add filtering and time-range selection capabilities
5. Create exportable reports for hat usage data

## 📊 Data Source

**Primary Data File:** `.claude/data/hat_usage_statistics.json`

This file contains:
- Total sessions per hat
- Total duration minutes per hat
- Tasks completed per hat
- Average session duration
- Daily breakdown of usage
- Session history with timestamps and **execution mode flag**
- Task associations showing which hats worked on which tasks
- **Execution mode statistics** (orchestrator vs spawned agent)

### 🎭 Execution Mode Tracking

Each session and task now includes:
- `execution_mode`: "orchestrator" or "spawned_agent"
- `is_orchestrator`: boolean flag for quick filtering
- `completed_by_orchestrator`: indicates if task was done by orchestrator wearing hat

**Icons:**
- 🎭 = Orchestrator wearing hat (can write/edit files)
- 🤖 = Spawned agent via Task tool (sandboxed, read-only)

## 🔧 Implementation Requirements

### Backend (Spring Boot)

1. **Create HatUsageController** (`/api/v1/admin/hat-usage/*`)
   ```java
   GET /api/v1/admin/hat-usage/statistics
   GET /api/v1/admin/hat-usage/daily/{date}
   GET /api/v1/admin/hat-usage/trends
   GET /api/v1/admin/hat-usage/export
   ```

2. **Create HatUsageService**
   - Read from `.claude/data/hat_usage_statistics.json`
   - Calculate trends and percentages
   - Generate time-series data
   - Support date range filtering

3. **Create DTOs**
   - HatUsageStatisticsDTO
   - HatUsageSessionDTO
   - HatUsageTrendDTO
   - HatUsageDailyBreakdownDTO

### Frontend (Flutter Admin Dashboard)

1. **Dashboard Components**

   a. **Overview Cards** (Top Section)
   - Total hats used
   - Most used hat
   - Total session time
   - Tasks completed (split: 🎭 Orchestrator / 🤖 Agent)
   - Active sessions
   - Execution mode ratio (% orchestrator vs % spawned)

   b. **Usage Distribution Chart** (Pie/Donut Chart)
   - Show percentage of time spent in each hat
   - Interactive tooltips with details
   - Color-coded by hat colors from data file

   c. **Timeline View** (Line/Area Chart)
   - Sessions over time by hat
   - Stacked area chart showing cumulative usage
   - Time range selector (day/week/month/all)

   d. **Hat Ranking Table**
   ```
   | Hat Name | Sessions | Total Time | Avg Session | Tasks (🎭/🤖) | Mode % | Last Used |
   |----------|----------|------------|-------------|---------------|--------|-----------|
   | Backend  | 45       | 1,230 min  | 27.3 min    | 12 (11/1)    | 92% 🎭 | 2 hrs ago |
   | UI Design| 32       | 890 min    | 27.8 min    | 8 (8/0)      | 100% 🎭| 5 hrs ago |
   | DevOps   | 28       | 645 min    | 23.0 min    | 6 (6/0)      | 100% 🎭| 1 day ago |
   | ...      | ...      | ...        | ...         | ...           | ...    | ...       |
   ```
   Mode % shows percentage of work done by orchestrator vs spawned agents

   e. **Task Association View**
   - Show which hats collaborated on tasks
   - Multi-hat task indicators
   - Task completion status by primary hat

   f. **Session History Log**
   - Scrollable list of recent sessions
   - Filter by hat, date, task
   - Export capability

2. **Visual Design Requirements**
   - Use hat colors from `hat_usage_statistics.json`
   - Material Design 3 components
   - Responsive layout for different screen sizes
   - Dark mode support
   - Smooth animations for data updates

3. **Interactive Features**
   - Click on chart segments to filter
   - Hover tooltips with detailed information
   - Date range picker
   - Export data as CSV/JSON
   - Real-time updates via WebSocket

## 📱 UI Mockup Structure

```
┌─────────────────────────────────────────────────┐
│            Hat Usage Statistics                 │
│  [Date Range: Last 7 Days ▼] [Export] [Refresh]│
├─────────────────────────────────────────────────┤
│ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ │
│ │ Total │ │ Most │ │Active│ │ Tasks│ │ Avg. │ │
│ │ Hats  │ │ Used │ │ Now  │ │ Done │ │Session│ │
│ │  14   │ │Backend│ │  1   │ │  47  │ │27 min │ │
│ └──────┘ └──────┘ └──────┘ └──────┘ └──────┘ │
├─────────────────────────────────────────────────┤
│     Distribution          │    Timeline         │
│   ┌─────────────┐        │  ┌──────────────┐  │
│   │             │        │  │  ╱╲    ╱╲    │  │
│   │  Pie Chart  │        │  │ ╱  ╲__╱  ╲   │  │
│   │             │        │  │╱           ╲  │  │
│   └─────────────┘        │  └──────────────┘  │
├─────────────────────────────────────────────────┤
│              Hat Ranking Table                  │
│ ┌───────────────────────────────────────────┐ │
│ │ Hat          Sessions  Time    Tasks      │ │
│ │ Backend Eng.    45     1230m    12        │ │
│ │ UI Designer     32     890m     8         │ │
│ │ DevOps Lead     28     645m     6         │ │
│ └───────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

## 🔨 Technical Implementation Details

### Charts Library Options (Flutter)
- **fl_chart**: Full-featured, customizable charts
- **syncfusion_flutter_charts**: Professional charts with good performance
- **charts_flutter**: Google's official charts (less maintained)

**Recommendation:** Use `fl_chart` for flexibility and active maintenance

### State Management
- Use Riverpod for state management
- Create providers for:
  - HatUsageStatisticsProvider
  - DateRangeFilterProvider
  - SelectedHatFilterProvider

### Caching Strategy
- Cache statistics for 5 minutes
- Implement pull-to-refresh
- WebSocket for real-time updates when orchestrator logs activity

## 🧪 Testing Requirements

1. **Backend Tests**
   - Unit tests for HatUsageService
   - Integration tests for controller endpoints
   - Test JSON file parsing and error handling

2. **Frontend Tests**
   - Widget tests for each dashboard component
   - Integration tests for data fetching
   - Test chart rendering with various data sets

## 📈 Success Metrics

- Dashboard loads within 2 seconds
- Charts render smoothly with up to 1000 data points
- Export functionality works for all data formats
- Real-time updates appear within 1 second
- Mobile responsive design works on all screen sizes

## 🎨 Hat Color Reference

Use these colors from the statistics file:
- project-manager: #9b59b6 (Purple)
- solution-architect: #34495e (Dark Gray)
- senior-backend-engineer: #2ecc71 (Green)
- principal-database-architect: #3498db (Blue)
- test-master: #e74c3c (Red)
- devops-lead: #f39c12 (Orange)
- ui-designer: #e91e63 (Pink)
- web-dev-master: #00bcd4 (Cyan)
- senior-mobile-developer: #4caf50 (Light Green)
- scrum-master: #ff9800 (Deep Orange)
- opportunist-strategist: #795548 (Brown)
- psychologist-game-dynamics: #9c27b0 (Deep Purple)
- game-theory-master: #673ab7 (Indigo)
- legal-software-advisor: #607d8b (Blue Gray)

## 📝 Additional Features (Phase 2)

1. **Predictive Analytics**
   - Predict which hat will be needed next
   - Suggest optimal hat switching patterns
   - Identify underutilized expertise areas

2. **Collaboration Matrix**
   - Show which hats work together most
   - Identify collaboration patterns
   - Suggest team composition for tasks

3. **Performance Metrics**
   - Track task completion rate by hat
   - Measure efficiency trends
   - Identify bottlenecks in expertise areas

4. **Alerts & Notifications**
   - Alert when a hat hasn't been used in X days
   - Notify about unusual usage patterns
   - Reminder to switch hats for long sessions

## 🚀 Implementation Steps

1. **Phase 1: Backend** (4 hours)
   - Create controller and service
   - Implement data reading from JSON
   - Create REST endpoints
   - Add authentication/authorization

2. **Phase 2: UI Design** (2 hours)
   - Design mockups in Figma/Sketch
   - Define component hierarchy
   - Create color palette and styling

3. **Phase 3: Frontend Implementation** (6 hours)
   - Build dashboard layout
   - Implement charts
   - Add interactivity
   - Connect to backend API
   - Add export functionality

4. **Phase 4: Testing & Polish** (2 hours)
   - Write tests
   - Fix bugs
   - Optimize performance
   - Add documentation

## 📚 Related Documentation

- [Hat Usage Statistics Schema](../data/hat_usage_statistics.json)
- [Orchestrator Logging Guide](../docs/references/ORCHESTRATOR_LOGGING_GUIDE.md)
- [Admin Dashboard Architecture](../../docs/ADMIN_DASHBOARD_ARCHITECTURE.md)

## ✅ Acceptance Criteria

- [ ] API endpoints return hat usage statistics
- [ ] Dashboard displays all key metrics
- [ ] Charts are interactive and responsive
- [ ] Data can be filtered by date range
- [ ] Export functionality works for CSV and JSON
- [ ] Real-time updates work via WebSocket
- [ ] Mobile responsive design is implemented
- [ ] All tests pass with >80% coverage
- [ ] Documentation is complete
- [ ] Performance metrics are met

## 🏁 Definition of Done

- Code is reviewed and approved
- All tests pass
- Documentation is updated
- Feature is deployed to staging
- Product owner approves implementation
- Monitoring is set up for new endpoints

---

**Note:** This task requires coordination between UI Designer, Web Dev Master, and Senior Backend Engineer hats. The orchestrator should switch hats appropriately as they progress through different phases of implementation.