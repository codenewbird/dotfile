#!/usr/bin/env bash

# 壁纸目录（按需修改）
WALLPAPER_DIR="/home/zjx/Pictures/wallpaper"



# 缓存文件
CACHE_DIR="$HOME/.cache/wallpaper_selector"
WALLPAPER_LIST="$CACHE_DIR/wallpapers.txt"
CURRENT_WALLPAPER="$CACHE_DIR/current"

# 创建缓存目录
mkdir -p "$CACHE_DIR"

# 生成壁纸列表（带缩略图）
generate_wallpaper_list() {
    # 查找所有壁纸文件
    find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) > "$WALLPAPER_LIST"
    
    # 为每个壁纸生成缩略图
    while IFS= read -r wallpaper; do
        thumb="${CACHE_DIR}/$(basename "$wallpaper" | md5sum | cut -d' ' -f1).jpg"
        if [[ ! -f "$thumb" ]]; then
            convert "$wallpaper" -thumbnail 200x200^ -gravity center -extent 200x200 "$thumb" 2>/dev/null
        fi
    done < "$WALLPAPER_LIST"
}

# 更新壁纸列表（如果目录有变化）
if [[ ! -f "$WALLPAPER_LIST" ]] || [[ $(find "$WALLPAPER_DIR" -newer "$WALLPAPER_LIST" | wc -l) -gt 0 ]]; then
    generate_wallpaper_list
fi

# 获取当前壁纸路径
current_wallpaper=""
if [[ -f "$CURRENT_WALLPAPER" ]]; then
    current_wallpaper=$(cat "$CURRENT_WALLPAPER")
fi

# 创建Rofi菜单项
rofi_items=""
while IFS= read -r wallpaper; do
    thumb="${CACHE_DIR}/$(basename "$wallpaper" | md5sum | cut -d' ' -f1).jpg"
    name=$(basename "$wallpaper")
    
    # 标记当前壁纸
    if [[ "$wallpaper" == "$current_wallpaper" ]]; then
        rofi_items+="\0message\x1fCurrent\n"
    else
        rofi_items+="\n"
    fi
    
    rofi_items+="![]($thumb)\t$name"
done < "$WALLPAPER_LIST"

# 使用Rofi显示选择菜单
selected=$(echo -e "$rofi_items" | rofi -dmenu -p "选择壁纸"  -markup-rows -i)

# 提取选择的壁纸路径
selected_wallpaper=$(echo "$selected" | awk -F'\t' '{print $2}')
if [[ -n "$selected_wallpaper" ]]; then
    # 查找完整路径
    selected_path=$(grep -m1 "$selected_wallpaper" "$WALLPAPER_LIST")
    
    if [[ -n "$selected_path" ]]; then
        # 设置新壁纸
        monitors=$(hyprctl monitors | grep -oP 'Monitor \K[^ ]+')
        for monitor in $monitors; do
            hyprctl hyprpaper preload "$selected_path"
            hyprctl hyprpaper wallpaper "$monitor,$selected_path"
        done
        
        # 保存当前壁纸路径
        echo "$selected_path" > "$CURRENT_WALLPAPER"
    fi
fi
