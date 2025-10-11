# 🎭 Orchestrator Framework

> A revolutionary AI orchestration system that transforms how AI assistants manage complex software projects through specialized expertise domains.

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](manifest.json)
[![Platform](https://img.shields.io/badge/platform-windows%20%7C%20linux%20%7C%20macos-lightgrey.svg)](manifest.json)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## 🚀 What is the Orchestrator Framework?

The Orchestrator Framework is a comprehensive system that enables AI assistants to work more effectively by "wearing different hats" - each representing a specialized domain of expertise. Instead of being a generalist, the AI becomes a master of context-switching, applying the right expertise at the right time.

### Core Philosophy

**You don't use an orchestrator - you ARE the orchestrator.**

This fundamental shift in perspective means:
- 🎯 **Focused Expertise**: Apply specialized knowledge for each task domain
- 🔄 **Seamless Transitions**: Switch between roles as the work demands
- 📊 **Complete Tracking**: Monitor all work across all domains
- ⚡ **Enforced Best Practices**: Never work without appropriate expertise

## 📦 Quick Start

### Windows Installation

```powershell
# Clone or download the framework
git clone https://github.com/your-org/orchestrator-framework.git
cd orchestrator-framework

# Run the initialization script
powershell.exe -ExecutionPolicy Bypass -File framework/init-orchestrator.ps1

# Start your first session
.\.claude\tools\orchestrator-session-start
```

### Linux/macOS Installation

```bash
# Clone or download the framework
git clone https://github.com/your-org/orchestrator-framework.git
cd orchestrator-framework

# Run the initialization script
bash framework/init-orchestrator.sh

# Start your first session
./.claude/tools/orchestrator-session-start
```

## 🎭 Available Agent Hats

The framework includes 14 specialized roles:

| Hat | Icon | Domain | When to Wear |
|-----|------|--------|--------------|
| `project-manager` | 📊 | Strategic Planning | Sprint planning, backlog prioritization |
| `solution-architect` | 🏗️ | System Design | Architecture decisions, tech stack choices |
| `senior-backend-engineer` | ⚙️ | Backend Development | API implementation, server-side logic |
| `principal-database-architect` | 🗄️ | Data Systems | Schema design, query optimization |
| `test-master` | 🧪 | Quality Assurance | Test strategy, automation |
| `devops-lead` | 🚀 | Infrastructure | CI/CD, deployment, monitoring |
| `ui-designer` | 🎨 | User Experience | Interface design, UX patterns |
| `web-dev-master` | 🌐 | Frontend Web | React/Vue/Angular implementation |
| `senior-mobile-developer` | 📱 | Mobile Apps | Flutter/React Native development |
| `scrum-master` | 🏃 | Agile Process | Sprint facilitation, impediment removal |
| `opportunist-strategist` | 🎯 | Market Intelligence | Competitive analysis, opportunities |
| `psychologist-game-dynamics` | 🧠 | User Psychology | Gamification, engagement strategies |
| `game-theory-master` | ♟️ | Strategic Analysis | Decision modeling, outcome prediction |
| `legal-software-advisor` | ⚖️ | Compliance | Licensing, regulatory requirements |

## 🔧 Basic Usage

### 1. Starting Work

```bash
# Always start with selecting a hat
./.claude/tools/orchestrator-log \
  --role senior-backend-engineer \
  --status in_progress \
  --emotion focused \
  --task TASK-001 \
  "Implementing user authentication API"
```

### 2. Switching Hats

```bash
# Complete current work
./.claude/tools/orchestrator-log --role senior-backend-engineer --status done "API complete"

# Switch to testing
./.claude/tools/orchestrator-log --role test-master --status in_progress "Writing API tests"
```

### 3. Checking Status

```bash
# See current hat
./.claude/tools/check-current-hat

# Get suggestions for next hat
./.claude/tools/check-current-hat --suggest
```

## 📈 Features

### 🛡️ Hat Enforcement
Prevents any work from being done without wearing an appropriate expertise hat. This ensures:
- Consistent quality across all work
- Proper expertise application
- Clear accountability and tracking

### 📊 Usage Analytics
Track how different hats are used:
- Frequency of hat usage
- Task completion rates
- Natural transition patterns
- Time spent in each role

### 🔄 Natural Transitions
The framework suggests logical next steps:
- Backend → Testing
- Design → Implementation
- Testing → Deployment
- Deployment → Project Management

### 🔗 Git Integration
Optional git hooks ensure:
- Commits include hat information
- Work is properly attributed
- History shows expertise applied

## 🏗️ Architecture

```
project-root/
├── .claude/                    # Framework core
│   ├── agents/                 # Role definitions
│   ├── tools/                  # Executable scripts
│   ├── data/                   # Usage statistics
│   ├── docs/                   # Documentation
│   └── status.json            # System state
├── framework/                  # Distribution files
│   ├── init-orchestrator.ps1  # Windows installer
│   ├── init-orchestrator.sh   # Unix installer
│   ├── manifest.json          # Package manifest
│   └── README.md              # This file
└── ORCHESTRATOR_START_HERE.md # Entry point

```

## 🔄 Workflow Example

Here's a typical development workflow:

```bash
# 1. Start session as architect to design
./.claude/tools/orchestrator-log --role solution-architect --status in_progress "Designing payment system"

# 2. Switch to backend for implementation
./.claude/tools/orchestrator-log --role senior-backend-engineer --status in_progress "Implementing payment API"

# 3. Switch to database for schema
./.claude/tools/orchestrator-log --role principal-database-architect --status in_progress "Creating payment tables"

# 4. Back to backend to integrate
./.claude/tools/orchestrator-log --role senior-backend-engineer --status in_progress "Integrating payment database"

# 5. Switch to testing
./.claude/tools/orchestrator-log --role test-master --status in_progress "Writing payment tests"

# 6. Finally deploy
./.claude/tools/orchestrator-log --role devops-lead --status in_progress "Deploying payment service"
```

## 📚 Documentation

- **Complete Guide**: [ORCHESTRATOR_FRAMEWORK_CREATION_GUIDE.md](ORCHESTRATOR_FRAMEWORK_CREATION_GUIDE.md)
- **Quick Start**: `.claude/ORCHESTRATOR_QUICK_START.md`
- **Architecture**: `.claude/docs/references/`
- **Agent Roles**: `.claude/agents/`

## 🤝 Contributing

We welcome contributions! Areas of interest:
- New agent role definitions
- Enhanced tracking capabilities
- Integration with more AI platforms
- Improved transition suggestions

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/your-org/orchestrator-framework/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/orchestrator-framework/discussions)
- **Community**: [Discord Server](https://discord.gg/orchestrator-framework)

## ✨ Why Use This Framework?

1. **Consistency**: Every task gets the right expertise applied
2. **Accountability**: Complete tracking of who did what and when
3. **Quality**: Specialized knowledge for specialized tasks
4. **Efficiency**: Natural workflow transitions reduce context switching
5. **Scalability**: Easy to add new roles as needs grow

## 🎯 Getting Started

After installation, your first steps should be:

1. **Read the guide**: Start with `ORCHESTRATOR_START_HERE.md`
2. **Initialize a session**: Run `orchestrator-session-start`
3. **Choose your first hat**: Based on your immediate task
4. **Start working**: Log your progress with `orchestrator-log`
5. **Switch as needed**: Change hats when the domain changes

Remember: You ARE the orchestrator. Each hat is just a different aspect of your capabilities!

---

*Built with 🎭 by the Orchestrator Framework Team*