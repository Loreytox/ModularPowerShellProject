# ModularPowershellProject

This project is a long-term effort to build a modular, scalable PowerShell tool that automates small, repetitive tasks to make daily work easier and more efficient. Over time, new features will be added to handle various automation needs, such as file management, system checks, or other helpful utilities.

The project is designed to be modular, meaning each feature will be built as an independent component. This ensures the tool remains organized, easy to update, and adaptable to future needs. By focusing on simplicity and reusability, the goal is to create a tool that grows with time while remaining easy to maintain.

It’s worth noting that this is only the second time I’m working with PowerShell, so this project will also serve as a learning experience. The focus will be on writing clean, efficient code and improving my understanding of PowerShell’s capabilities as the project evolves.

This is a hands-on, evolving project, and the emphasis will be on thoughtful design and continuous improvement.

## Day 2: 21.02.2025

Today I searched for the most reasonable script that someone might find useful, for example the search and relocation of files. These files might be hidden in a folder somewhere with over 1k other files and it might be hard to move them all. I searched on StackOverflow and found a script that would do the job, but I found the sccript to be not so user-friendly which is why I decided to change it and implement a Read-Host input type. This way, the user is able to specify which file he wants with ease. I think that this module for the multi-modular project is a good stepping stone to start on.

![image](https://github.com/user-attachments/assets/5d134876-fa13-4b38-8514-28d24f73b525)

This is the source code that I used to get started:
https://stackoverflow.com/questions/38063424/powershell-move-all-files-from-folders-and-subfolders-into-single-folder

## Day 3: 28/03/2025
Today I moslty worked on a GUI and trying to make my modular project modular. I didn't quite get how to show the scripts in the GUI and also wanted an easy solution as to be able to easily change and add things, since I will be adding more scripts over the course of this project.

![image](https://github.com/user-attachments/assets/f0422b2f-e4ae-40fd-b30d-8fea1b1e7a90)

This is the GUI and although simple, it serves its purpose.

![image](https://github.com/user-attachments/assets/057a152a-7ed8-4fb7-bc0a-bdadb50e6cf5)

And here is what the script does:
This is a simple script that when it's run, it shows various System specs, which is fast and convenient, since one doesn't have to open settings and other things.

I was heavily inspired by this code here:
https://www.elevenforum.com/t/collecting-system-information-using-powershell-script.32808/

## Day 4: 04/04/2025
For today's project I wanted to implement a script that when run, it would delete all unnecessary TEMP and BROWSER Files. These files are usually just temporary files and take only space away for the PC, so when I noticed that my available space was getting low, I decided to implement it.
I research for a little bit, as well as watched a video on how to to it, but it was for Windows 10 and not 11, so I couldn't just do as he did, but it nontheless helped me understand how it would work. I also found a public repository on GitHub with some PowerShell commands to delete said files.

![image](https://github.com/user-attachments/assets/af6982fc-7453-478a-b445-a26b80ed01de)

This is what the user would see, once he ran the script. I also implemented a dry-run option, as to not accidentally delete important files.

Here are some sources that I relied on:
https://github.com/kamrullab/WindowsCleanupCommands

https://www.youtube.com/watch?v=vJYzHTRh-pE
