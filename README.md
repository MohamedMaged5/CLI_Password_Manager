# CLI_Password_Manager
A simple CLI Password Manager built with Bash that encrypts and stores your passwords securely using OpenSSL — all from your terminal.




https://github.com/user-attachments/assets/214f5e72-f945-48fb-b267-3e1e05417d9c


## Features:
🔐 𝗠𝗮𝘀𝘁𝗲𝗿 𝗣𝗮𝘀𝘀𝘄𝗼𝗿𝗱 𝗣𝗿𝗼𝘁𝗲𝗰𝘁𝗶𝗼𝗻: single password gates access to the entire vault.

🔒 𝗔𝗘𝗦-𝟮𝟱𝟲-𝗖𝗕𝗖 𝗘𝗻𝗰𝗿𝘆𝗽𝘁𝗶𝗼𝗻: every entry is encrypted before saving, nothing stored in plain text.

✅ 𝗣𝗮𝘀𝘀𝘄𝗼𝗿𝗱 𝗩𝗲𝗿𝗶𝗳𝗶𝗰𝗮𝘁𝗶𝗼𝗻: master password is verified via SHA-256 hash on every login.

➕ 𝗔𝗱𝗱 𝗣𝗮𝘀𝘀𝘄𝗼𝗿𝗱𝘀: save website, username/email, and password securely.

🚫 𝗡𝗼 𝗗𝘂𝗽𝗹𝗶𝗰𝗮𝘁𝗲 𝗘𝗻𝘁𝗿𝗶𝗲𝘀: if the website already exists, it blocks the entry and alerts you immediately.

📋 𝗟𝗶𝘀𝘁 𝗔𝗹𝗹 𝗣𝗮𝘀𝘀𝘄𝗼𝗿𝗱𝘀: view all saved entries decrypted in a formatted table.

🔎 𝗦𝗲𝗮𝗿𝗰𝗵 𝗯𝘆 𝗪𝗲𝗯𝘀𝗶𝘁𝗲: quickly retrieve a specific entry.

🗑️ 𝗗𝗲𝗹𝗲𝘁𝗲 𝗣𝗮𝘀𝘀𝘄𝗼𝗿𝗱𝘀: remove any saved entry by website name.

⚠️ 𝗜𝗻𝗽𝘂𝘁 𝗩𝗮𝗹𝗶𝗱𝗮𝘁𝗶𝗼𝗻: no empty fields allowed.

🎨 𝗖𝗼𝗹𝗼𝗿𝗲𝗱 𝗖𝗟𝗜 𝗜𝗻𝘁𝗲𝗿𝗳𝗮𝗰𝗲: clean and readable terminal UI.

## 𝗧𝗲𝗰𝗵 𝗦𝘁𝗮𝗰𝗸:
🖥️ 𝗕𝗮𝘀𝗵: Core scripting language.

🔐 𝗢𝗽𝗲𝗻𝗦𝗦𝗟: AES-256-CBC encryption & SHA-256 hashing.

🧠 𝗣𝗕𝗞𝗗𝗙𝟮: Master password key derivation.

📦 𝗕𝗮𝘀𝗲𝟲𝟰: Encrypted data encoding for file storage.

