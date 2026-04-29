# Professional Init System (PID 1)
### Beyond Systemd - The Pure Power of Simplicity

This is an independent, minimalist, and high-performance **Init System** designed for users who value the **KISS** (Keep It Simple, Stupid) principle. Unlike complex binary init systems, this project is built for transparency and speed.

## 🚀 Why this system?
* **Lightning Fast:** Parallel service execution using background subshells.
* **Pure Bash/Sh:** 100% transparent code. No hidden binaries.
* **Self-Healing:** Built-in Watchdog Manager that restarts crashed services automatically.
* **Modular Design:** Runit-style directory structure for easy service management.

## 📁 System Architecture
* \`init.sh\`: The core entry point for the Kernel.
* \`core/manager.sh\`: The brain that monitors and dispatches services.
* \`core/utils.sh\`: The Swiss Army Knife for system states (Reboot/Shutdown).
* \`services/\`: Individual directories for each system task.

## 🛠 Installation & Build
1. Clone the repository.
2. Run the build script:
   \`\`\`bash
   chmod +x build.sh && ./build.sh
   \`\`\`
3. Launch the system:
   \`\`\`bash
   ./init.sh
   \`\`\`

## ⚖️ License
Open Source - Created for the community of Debian, Arch, and minimalist Linux lovers.
