# Project Board Design Specification

## 🎯 Objective
Design a comprehensive project board dashboard for The Chain project that provides real-time visibility into project status, agent activities, and development progress using the existing Mystique dark theme components.

## 🎨 Design Requirements

### Theme & Style
- **Design System**: Use the existing Dark Mystique theme
- **Color Palette**:
  - Primary: Mystic Violet (#9B59B6)
  - Secondary: Ghost Cyan (#00E5FF)
  - Background: Void Black (#0A0A0F)
  - Surface: Shadow Purple (#1A1625)
  - Success: Green Glow (#4CAF50)
  - Warning: Orange Aura (#FF9800)
  - Error: Red Pulse (#F44336)
- **Typography**: System default with letter-spacing for headers
- **Spacing**: 8-point grid system

### Layout Structure

```
┌─────────────────────────────────────────────────────────┐
│  Header: Project Board - The Chain                       │
│  [Real-time indicator] Last Updated: 2 seconds ago       │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌─── Project Overview ──────────┬─── Quick Stats ────┐ │
│  │                               │                     │ │
│  │  Current Sprint: Sprint 12    │  ▣ Total Tasks: 47  │ │
│  │  Progress: ████████░░ 78%     │  ✓ Completed: 37    │ │
│  │  Days Remaining: 3            │  ⟳ In Progress: 8   │ │
│  │  Velocity: 42 pts/sprint      │  ○ Pending: 2       │ │
│  └───────────────────────────────┴─────────────────────┘ │
│                                                           │
│  ┌─── Agent Status Grid ────────────────────────────────┐ │
│  │  [Grid of agent cards showing status]                │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                           │
│  ┌─── Activity Timeline ─────────┬─── System Health ────┐ │
│  │  [Real-time logs]            │  [Metrics]          │ │
│  └───────────────────────────────┴─────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## 📊 Component Specifications

### 1. Header Section
- **Title**: "Project Board - The Chain" with gradient text effect
- **Real-time Status**: Pulsing indicator showing connection status
- **Last Update**: Auto-updating timestamp
- **Actions**: Settings gear icon, full-screen toggle

### 2. Project Overview Card
Use `MystiqueCard` with elevated style:
- **Current Sprint**: Display sprint number and name
- **Progress Bar**: Custom animated progress with glow effect
- **Time Tracking**: Countdown to sprint end
- **Velocity Chart**: Mini sparkline showing last 5 sprints

### 3. Quick Stats Panel
Use multiple `MystiqueStatCard` components:
- **Total Tasks**: Icon: `Icons.task_alt`
- **Completed**: Green accent, Icon: `Icons.check_circle`
- **In Progress**: Cyan accent, Icon: `Icons.refresh`
- **Blocked**: Red accent, Icon: `Icons.block`

### 4. Agent Status Grid

#### Agent Card Design (200x250px each)
```
┌─────────────────────┐
│  [Avatar/Icon]      │
│  Agent Name         │
│  Role Title         │
│  ───────────────    │
│  Status: [Badge]    │
│  Emotion: [Emoji]   │
│  Current Task:      │
│  [Task description] │
│  ───────────────    │
│  Last Active: 2m    │
│  [Progress Bar]     │
└─────────────────────┘
```

**Agent States**:
- **Active**: Glowing border animation (cyan)
- **Idle**: Default purple border
- **Blocked**: Red border with pulse
- **Working**: Green border with activity spinner

**Emotion Indicators**:
- 😊 Happy (green glow)
- 😐 Neutral (no effect)
- 😔 Sad (blue tint)
- 😤 Frustrated (orange pulse)
- 😌 Satisfied (soft green)

### 5. Activity Timeline
Scrollable log viewer with:
- **Entry Format**: `[Time] [Agent] [Action] [Details]`
- **Color Coding**:
  - Success events: Green text
  - Errors: Red text
  - Info: Default purple
  - Warnings: Orange
- **Filters**: By agent, by type, by time range
- **Auto-scroll**: Toggle for following latest

### 6. System Health Panel
- **API Status**: Green/Red indicator
- **Database**: Connection pool usage gauge
- **Redis Cache**: Hit rate percentage
- **Build Status**: Last CI/CD run result
- **Error Rate**: Graph showing last hour

## 🎯 Interactive Features

### 1. Agent Cards
- **Click**: Expand to show detailed logs
- **Hover**: Show tooltip with full task description
- **Right-click**: Context menu (View logs, Assign task, Message)

### 2. Real-time Updates
- **WebSocket Connection**: Live data feed
- **Polling Fallback**: Every 5 seconds if WebSocket fails
- **Notification Toast**: For critical events

### 3. Filtering & Search
- **Agent Filter**: Checkbox list to show/hide agents
- **Status Filter**: Show only active/blocked/idle
- **Search Bar**: Filter logs by keyword
- **Time Range**: Last hour/day/week selector

## 📱 Responsive Design

### Desktop (1920x1080)
- 4-column agent grid
- Side-by-side timeline and health panels
- Full feature set

### Tablet (1024x768)
- 3-column agent grid
- Stacked timeline and health panels
- Collapsible sidebar

### Mobile (375x812)
- Single column layout
- Swipeable agent cards
- Condensed stats view
- Bottom navigation tabs

## 🔔 Data Sources

### From `.claude/status.json`
```json
{
  "agents": {
    "agent-name": {
      "status": "active|idle|blocked",
      "emotion": "happy|sad|neutral|frustrated|satisfied",
      "current_task": "Task description or null",
      "last_activity": "ISO timestamp"
    }
  }
}
```

### From Agent Logs (`.claude/logs/*.log`)
- JSONL format with timestamp, action, details
- Parse and display in timeline

### From Backend API
- `/api/v1/project/stats` - Project metrics
- `/api/v1/chain/health` - System health
- `/api/v1/tasks/current` - Sprint tasks

## 🎨 Visual Effects

### Animations
1. **Glow Effects**: Subtle breathing glow on active elements
2. **Progress Bars**: Smooth transitions with gradient fill
3. **Card Hover**: Slight elevation with shadow expansion
4. **Status Changes**: Fade transition between states
5. **Loading States**: Use `MystiqueLoadingIndicator`

### Background Elements
- Subtle chain link pattern overlay (5% opacity)
- Gradient mesh background (purple to black)
- Particle effects for celebrations (task completion)

## 🛠 Implementation Notes

### Technology Stack
- **Framework**: Flutter Web
- **State Management**: Provider or Riverpod
- **Real-time**: WebSocket or Server-Sent Events
- **Charts**: fl_chart package
- **Animations**: Flutter's animation framework

### Component Library Usage
Use existing Mystique components:
- `MystiqueCard` for all card layouts
- `MystiqueButton` for actions
- `MystiqueTextField` for search/filter inputs
- `MystiqueStatCard` for metrics
- `MystiqueAlert` for notifications
- `MystiqueLoadingIndicator` for loading states

### Performance Considerations
- Virtual scrolling for logs (only render visible items)
- Debounce search input (300ms delay)
- Memoize computed values (statistics)
- Lazy load agent details
- Use `const` constructors where possible

## 📋 Accessibility

1. **Keyboard Navigation**: Tab through all interactive elements
2. **Screen Reader**: Proper ARIA labels
3. **Color Contrast**: Ensure WCAG AA compliance
4. **Font Size**: Minimum 14px, scalable to 200%
5. **Focus Indicators**: Visible focus rings

## 🚀 Future Enhancements

1. **Customizable Dashboard**: Drag-and-drop widgets
2. **Agent Communication**: Built-in chat/messaging
3. **Task Assignment**: Direct task creation from board
4. **Export Reports**: PDF/CSV generation
5. **Mobile App**: Native mobile version
6. **AI Insights**: Predictive analytics on project completion
7. **Gantt Chart View**: Timeline visualization
8. **Burndown Charts**: Sprint progress tracking

## 📝 Delivery Requirements

### From UI/UX Designer
1. **Figma/Sketch File**: Complete design mockups
2. **Component Library**: Reusable design components
3. **Interaction Prototype**: Clickable prototype
4. **Asset Export**: Icons, images in SVG/PNG
5. **Design Tokens**: Colors, spacing, typography specs
6. **Responsive Layouts**: Desktop, tablet, mobile views

### From Frontend Developer
1. **Flutter Web Application**: Fully functional dashboard
2. **Component Implementation**: All custom widgets
3. **API Integration**: Connected to backend services
4. **Real-time Updates**: WebSocket implementation
5. **State Management**: Clean architecture
6. **Unit Tests**: Widget and integration tests
7. **Documentation**: Code comments and README

## 🎯 Success Criteria

1. **Load Time**: < 2 seconds initial load
2. **Update Frequency**: Real-time or < 5 second delay
3. **Responsiveness**: Works on all screen sizes
4. **Browser Support**: Chrome, Firefox, Safari, Edge
5. **Error Handling**: Graceful degradation
6. **User Satisfaction**: Intuitive and visually appealing

---

## Example Code Structure

```dart
// Main Dashboard Widget
class ProjectBoard extends StatefulWidget {
  @override
  _ProjectBoardState createState() => _ProjectBoardState();
}

class _ProjectBoardState extends State<ProjectBoard> {
  // WebSocket connection
  // Agent status stream
  // Filter states

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkMystiqueTheme.voidBlack,
      body: Column(
        children: [
          ProjectHeader(),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      ProjectOverview(),
                      AgentGrid(),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      QuickStats(),
                      SystemHealth(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ActivityTimeline(),
        ],
      ),
    );
  }
}
```

This specification provides a complete blueprint for creating a modern, functional project board that leverages the existing Mystique UI components while providing comprehensive project visibility.