#!/usr/bin/env fish

# root 用户不建议使用此脚本
function yh_ud --description 'root 用户退出'
    if test "$USER" = 'root'
        echo '请先退出root用户，并登陆新创建的用户。'
        exit 1
    end
end

# 修改 pacman 配置
function pac_ud
    # pacman 增加 multilib 源
    sudo sed -i '/^#\[multilib\]/,+1s/^#//g' /etc/pacman.conf
    # pacman 开启颜色
    sudo sed -i '/^#Color$/s/#//' /etc/pacman.conf
    # 加上 archlinuxcn 源
    if not string match -q '*archlinuxcn*' < /etc/pacman.conf
        echo -e '[archlinuxcn]\nServer =  https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch' | sudo tee -a /etc/pacman.conf
        # 导入 GPG key
        sudo pacman -Syy --noconfirm archlinuxcn-keyring
    end
end

# 判断显卡驱动
function xk_ud
    if lspci -vnn | string match -iq '*vga*amd*radeon*'
        echo xf86-video-amdgpu
    else if lspci -vnn | string match -iq '*vga*nvidia*geforce*'
        #echo xf86-video-nouveau
        echo nvidia
    end
end

# pacman 安装软件
function pac_av
    # 更新系统
    sudo pacman -Syu --noconfirm
    # 缩写
    set pacn sudo pacman -S --noconfirm
    # btrfs 管理，网络管理器，tlp
    $pacn btrfs-progs networkmanager tlp tlp-rdw
    # 声卡，触摸板，显卡驱动
    $pacn alsa-utils pulseaudio-alsa xf86-input-libinput (xk_ud)
    # 繁简中日韩，emoji，Ubuntu字体
    $pacn noto-fonts-cjk noto-fonts-emoji ttf-ubuntu-font-family ttf-font-awesome
    # 小企鹅输入法
    $pacn fcitx5-im fcitx5-rime
    # wayland 显示服务器
    #$pacn wayland sway swaybg swayidle swaylock xorg-xwayland
    #$pacn wofi qt5-wayland
    # xorg 显示服务器
    $pacn xorg xorg-xinit i3-gaps i3lock rofi
    # 终端
    $pacn alacritty i3status-rust
    # 播放控制，亮度控制，电源工具
    $pacn playerctl brightnessctl upower lm_sensors
    # 网络工具
    $pacn curl firefox firefox-i18n-zh-cn git wget yay
    # 必要工具
    $pacn fish neovim nnn p7zip zsh
    # 模糊搜索，图片
    $pacn fzf imv pkgstats nftables dnscrypt-proxy
    # mtp，蓝牙
    $pacn libmtp pulseaudio-bluetooth bluez-utils
    # 其他工具
    $pacn libreoffice-fresh-zh-cn tree vlc vim
    # 编程语言
    $pacn bash-language-server clang lua nodejs rust yarn
    # 安装 arch
    $pacn arch-install-scripts dosfstools parted
    # steam
    $pacn gamemode ttf-liberation wqy-microhei wqy-zenhei steam
end

# 修改 yay 配置
function yay_ud
    yay --aururl 'https://aur.tuna.tsinghua.edu.cn' --save
end

# yay 安装软件
function yay_av
    # 安装 jmtpfs，starship
    yay -S --noconfirm jmtpfs starship
end

# 安装软件
function rj_av
    xk_ud
    pac_ud
    pac_av
    yay_ud
    yay_av
end

# 设置 fish
function fish_ud
    mkdir -p ~/.config/fish/conf.d
    # 更改默认 shell 为 fish
    sudo sed -i '/home/s/bash/fish/' /etc/passwd
    sudo sed -i '/root/s/bash/fish/' /etc/passwd
    # 安装 zlua
    wget -nv https://raw.githubusercontent.com/skywind3000/z.lua/master/z.lua -O ~/.config/fish/conf.d/z.lua
    echo 'source (lua ~/.config/fish/conf.d/z.lua --init fish | psub)' > ~/.config/fish/conf.d/z.fish
end

# 下载配置文件
function pvwj_ud
    # 创建目录
    mkdir -p ~/{a/vp/bv,gz,xz,.config/{alacritty,fcitx5,fish,i3status-rust,nvim/.backup,sway}}
    # 壁纸
    wget -nv https://github.com/rraayy246/uz/raw/master/pv/hw.png -O ~/a/vp/bv/hw.png
    # xinit
    echo 'exec i3' > ~/.xinitrc
    # 克隆 uz 仓库
    git clone https://github.com/rraayy246/uz ~/a/uz --depth 1
    # dns
    echo -e 'nameserver 127.0.0.1\noptions edns0 single-request-reopen' | sudo tee /etc/resolv.conf
    sudo chattr +i /etc/resolv.conf
    # 缩写
    set pvwj ~/a/uz/pv/
    # fish 设置环境变量
    fish {$pvwj}hjbl.fish
    # 链接配置文件
    sudo ln -f {$pvwj}dns /etc/dnscrypt-proxy/dnscrypt-proxy.toml
    sudo ln -f {$pvwj}fhq /etc/nftables.conf
    sudo ln -f {$pvwj}tlp /etc/tlp.conf
    ln -f {$pvwj}fish.fish ~/.config/fish/config.fish
    #ln -f {$pvwj}sway ~/.config/sway/config
    ln -f {$pvwj}i3 ~/.config/i3/config
    ln -f {$pvwj}urf ~/.config/fcitx5/profile
    ln -f {$pvwj}vtl.toml ~/.config/i3status-rust/config.toml
    ln -f {$pvwj}vd.yml ~/.config/alacritty/alacritty.yml
    ln -f {$pvwj}vim.vim ~/.config/nvim/init.vim
end

# 安装小鹤音形
# http://flypy.ys168.com/ 小鹤音形挂接第三方 小鹤音形Rime平台鼠须管for macOS.zip
function xhyx_av
    cd
    # 解压配置包
    7z x ~/a/uz/pv/flypy.7z
    mkdir -p ~/.local/share/fcitx5
    cp -rf ~/rime ~/.local/share/fcitx5
    rm -rf ~/rime
    # 重新加载 fcitx 配置
    fcitx5-remote -r
end

# 自启动管理
function zqd_ud
    sudo systemctl enable --now NetworkManager ;
    and sudo systemctl disable dhcpcd
    sudo systemctl enable --now {bluetooth,dnscrypt-proxy,NetworkManager-dispatcher,nftables,tlp} ;
    sudo systemctl mask {systemd-rfkill.service,systemd-rfkill.socket}
end

# 设置 vim
function vim_ud
    # 安装 vim-plug
    curl -fLo $HOME/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    # 插件下载
    nvim +PlugInstall +qall
end

# uz 设置。
function uz_ud
    ln -s ~/a/uz ~/
    cd ~/a/uz
    # 记忆账号密码
    git config credential.helper store
    git config --global user.email 'rraayy246@gmail.com'
    git config --global user.name 'ray'
    # 默认合并分支
    git config --global pull.rebase false
    cd
end

# 文字提醒
function wztx
    echo -e '\n'
end

# ======= 主程序 =======

yh_ud
switch $argv[1]
case a
    pac_av
case p
    pvwj_ud
case u
    uz_ud
case '*'
    rj_av
    fish_ud
    pvwj_ud
    xhyx_av
    zqd_ud
    vim_ud
    wztx
end

