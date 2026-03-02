PASSWORD_FILE="passwords.txt"
MASTER_HASH_FILE=".master_hash"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
MAGENTA='\033[1;35m'
BOLD='\033[1m'
RESET='\033[0m'

# Master password setup / verification
if [[ ! -f "$MASTER_HASH_FILE" ]]; then
    # First time — create a new master password
    echo -e "${YELLOW}No master password found, Let's create one.${RESET}"
    while true; do
        read -s -p "Create Master Password: " MASTER_PASS
        echo
        if [[ -z "$MASTER_PASS" ]]; then
            echo -e "${RED}Password cannot be empty, Try again.${RESET}"
            continue
        fi
        read -s -p "Confirm Master Password: " MASTER_PASS_CONFIRM
        echo
        if [[ "$MASTER_PASS" != "$MASTER_PASS_CONFIRM" ]]; then
            echo
            echo -e "${RED}Passwords do not match, Try again.${RESET}"
            echo
        else
            # Save SHA-256 hash of the master password
            printf '%s' "$MASTER_PASS" | openssl dgst -sha256 -hex | \
                awk '{print $2}' > "$MASTER_HASH_FILE"
            echo
            echo -e "${GREEN}Master password created successfully!${RESET}"
            echo -e "${YELLOW}Please remember this password, It is required to access your vault.${RESET}"
            echo
            break
        fi
    done
else
    # Existing master password — ask for master it
    read -s -p "Enter Master Password: " MASTER_PASS
    echo
    entered_hash=$(printf '%s' "$MASTER_PASS" | openssl dgst -sha256 -hex | awk '{print $2}')
    stored_hash=$(cat "$MASTER_HASH_FILE")
    if [[ "$entered_hash" != "$stored_hash" ]]; then
        echo
        echo -e "${RED}Wrong master password, Access denied.${RESET}"
        exit 1
    fi
    echo
    echo -e "${GREEN}Master password verified.${RESET}"
    echo
fi

# encrypt one line
encrypt_line() {
    # stdin → AES-256-CBC encrypted → base64 single line
    openssl enc -aes-256-cbc -pbkdf2 -a -A \
        -pass pass:"$MASTER_PASS" 2>/dev/null
}

# decrypt one line
decrypt_line() {
    # stdin (base64 encrypted) → plain text
    openssl enc -aes-256-cbc -pbkdf2 -d -a -A \
        -pass pass:"$MASTER_PASS" 2>/dev/null
}

add_new_pass() {
    read -p "Website: " website
    if [[ -z "$website" ]]; then
        echo
        echo -e "${RED}Website cannot be empty.${RESET}"
        return
    fi

    # Check for duplicate website
    if [[ -f "$PASSWORD_FILE" ]] && [[ -s "$PASSWORD_FILE" ]]; then
        while IFS= read -r encrypted_line; do
            [[ -z "$encrypted_line" ]] && continue
            plain=$(printf '%s' "$encrypted_line" | decrypt_line)
            [[ -z "$plain" ]] && continue
            IFS=':' read -r w _ _ <<< "$plain"
            if [[ "$w" == "$website" ]]; then
                echo
                echo -e "${RED}$website already exists. Use a different name or delete it first.${RESET}"
                return
            fi
        done < "$PASSWORD_FILE"
    fi

    read -p "Username or Email: " username
    if [[ -z "$username" ]]; then
        echo
        echo -e "${RED}Username or Email cannot be empty.${RESET}"
        return
    fi

    read -s -p "Enter a new password: " new_pass
    echo
    if [[ -z "$new_pass" ]]; then
        echo    
        echo -e "${RED}Password cannot be empty.${RESET}"
        return
    fi

    # Encrypt the entry before saving
    encrypted=$(printf '%s' "$website:$username:$new_pass" | encrypt_line)
    if [[ -z "$encrypted" ]]; then
        echo -e "${RED}Encryption failed, Check your OpenSSL installation.${RESET}"
        return
    fi
    echo "$encrypted" >> "$PASSWORD_FILE"
    echo
    echo -e "${GREEN}Password for $website saved successfully (encrypted).${RESET}"
}

list_pass() {
    if [[ ! -f "$PASSWORD_FILE" ]] || [[ ! -s "$PASSWORD_FILE" ]]; then
        echo -e "${YELLOW}No passwords saved yet.${RESET}"
        return
    fi

    echo -e "${MAGENTA}=== Saved Passwords ===${RESET}"
    printf "${BOLD}%-40s | %-40s | %s${RESET}\n" "Website" "Username or Email" "Password"
    echo -e "${CYAN}--------------------------------------------------------------------------------------------------------------${RESET}"

    while IFS= read -r encrypted_line; do
        [[ -z "$encrypted_line" ]] && continue
        plain=$(printf '%s' "$encrypted_line" | decrypt_line)
        [[ -z "$plain" ]] && continue
        IFS=':' read -r website username password <<< "$plain"
        printf "%-40s | %-40s | ${GREEN}%s${RESET}\n" "$website" "$username" "$password"
        echo -e "${CYAN}--------------------------------------------------------------------------------------------------------------${RESET}"
    done < "$PASSWORD_FILE"
}

get_pass() {
    read -p "Enter the website: " website
    echo
    if [[ ! -f "$PASSWORD_FILE" ]]; then
        echo -e "${YELLOW}No passwords saved yet.${RESET}"
        return
    fi

    found=0
    while IFS= read -r encrypted_line; do
        [[ -z "$encrypted_line" ]] && continue
        plain=$(printf '%s' "$encrypted_line" | decrypt_line)
        [[ -z "$plain" ]] && continue
        IFS=':' read -r w u p <<< "$plain"
        if [[ "$w" == "$website" ]]; then
            echo -e "${CYAN}Website:${RESET} $w"
            echo -e "${CYAN}Username or Email:${RESET} $u"
            echo -e "${CYAN}Password:${RESET} ${GREEN}$p${RESET}"
            found=1
            break
        fi
    done < "$PASSWORD_FILE"

    [[ $found -eq 0 ]] && echo -e "${RED}Password for $website not found.${RESET}"
}

delete_pass() {
    read -p "Enter the website to delete: " website
    echo
    if [[ ! -f "$PASSWORD_FILE" ]]; then
        echo -e "${YELLOW}No passwords saved yet.${RESET}"
        return
    fi

    tmp_file="${PASSWORD_FILE}.tmp"
    : > "$tmp_file"          
    found=0

    while IFS= read -r encrypted_line; do
        [[ -z "$encrypted_line" ]] && continue
        plain=$(printf '%s' "$encrypted_line" | decrypt_line)
        if [[ -z "$plain" ]]; then
            continue
        fi
        IFS=':' read -r w _ _ <<< "$plain"
        if [[ "$w" == "$website" ]]; then
            found=1           
        else
            echo "$encrypted_line" >> "$tmp_file"
        fi
    done < "$PASSWORD_FILE"

    mv "$tmp_file" "$PASSWORD_FILE"

    if [[ $found -eq 1 ]]; then
        echo -e "${GREEN}Password for $website deleted successfully.${RESET}"
    else
        echo -e "${RED}Password for $website not found.${RESET}"
    fi
}

while true; do
    echo -e "${MAGENTA}=== Password Manager ===${RESET}"
    echo -e "${YELLOW}1)${RESET} Add New Password"
    echo -e "${YELLOW}2)${RESET} List Passwords"
    echo -e "${YELLOW}3)${RESET} Get Password"
    echo -e "${YELLOW}4)${RESET} Delete Password"
    echo -e "${RED}5)${RESET} Exit"
    read -p "Choose an option: " option
    echo
    case $option in
        1) add_new_pass ;;
        2) list_pass    ;;
        3) get_pass     ;;
        4) delete_pass  ;;
        5) echo -e "${CYAN}Goodbye!${RESET}" ; exit 0 ;;
        *) echo -e "${RED}Invalid option, Please choose a valid option.${RESET}" ;;
    esac
    echo
done

