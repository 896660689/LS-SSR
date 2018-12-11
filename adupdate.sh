#!/bin/sh

#kysdm(gxk7231@gmail.com) mod by mj for padavan adbyby

tmpdir="/tmp/ad"
adbybydir="/etc/storage/adb"
adbyby_data="/etc/storage/adb/data"
logger_title="[Adbyby]"

restart_ad(){
	/sbin/restart_adbyby
}

rm_cache(){
	rm -rf $tmpdir
	rm -f $adbybydir/data/*.bak
}

judge_update(){
	if [ "$lazy_online"x == "$lazy_local"x ]; then
		logger -t "${logger_title}" "本地lazy规则已经最新，无需更新"
		if [ "$video_online"x == "$video_local"x ]; then
			logger -t "${logger_title}" "本地video规则已经最新，无需更新"
			rm_cache && exit 0
		else
			logger -t "${logger_title}" "检测到video规则更新，下载规则中..."
			download_video;restart_ad
			rm_cache && exit 0
		fi
	else
		logger -t "${logger_title}" "检测到lazy规则更新，下载规则中..."
		if [ "$video_online"x == "$video_local"x ]; then
			logger -t "${logger_title}" "本地video规则已经最新，无需更新"
			download_lazy;restart_ad
			rm_cache && exit 0
		else
			logger -t "${logger_title}" "检测到video规则更新，下载规则中..."
			download_lazy;download_video;restart_ad
			rm_cache && exit 0
		fi
	fi
}

download_lazy(){

	wget -q -c -P $tmpdir 'https://coding.net/u/adbyby/p/xwhyc-rules/git/raw/master/lazy.txt'
		if [ "$?"x != "0"x ]; then
			logger -t "${logger_title}" "【lazy】下载coding中的规则失败，尝试下载github中的规则"
			wget -q -c -P $tmpdir 'https://raw.githubusercontent.com/adbyby/xwhyc-rules/master/lazy.txt'
			if [ "$?"x != "0"x ]; then
				logger -t "${logger_title}" "【lazy】双双失败GG，请检查网络"
			else
				logger -t "${logger_title}" "【lazy】下载成功，正在应用..."
				mv $tmpdir/lazy.txt $adbybydir/data/lazy.txt
			fi
		else
			logger -t "${logger_title}" "【lazy】下载成功，正在应用..."
			mv $tmpdir/lazy.txt $adbybydir/data/lazy.txt
		fi
}

download_video(){
	wget -q -c -P $tmpdir 'https://coding.net/u/adbyby/p/xwhyc-rules/git/raw/master/video.txt'
		if [ "$?"x != "0"x ]; then
			logger -t "${logger_title}" "【video】下载coding中的规则失败，尝试下载github中的规则"
			wget -q -c -P $tmpdir 'https://raw.githubusercontent.com/adbyby/xwhyc-rules/master/video.txt'
			if [ "$?"x != "0"x ]; then
				logger -t "${logger_title}" "【video】双双失败GG，请检查网络"
			else
				logger -t "${logger_title}" "【video】下载成功，正在应用..."
				mv $tmpdir/video.txt $adbybydir/data/video.txt
			fi
		else
			logger -t "${logger_title}" "【video】下载成功，正在应用..."
			mv $tmpdir/video.txt $adbyby_data/video.txt
		fi
}

# check_rules()

	rm_cache
	mkdir $tmpdir
	logger -t "${logger_title}" "自动检测规则更新中" && cd $tmpdir
	
	md5sum $adbyby_data/lazy.txt $adbyby_data/video.txt > local-md5.json
	wget-ssl --no-check-certificate https://coding.net/u/adbyby/p/xwhyc-rules/git/raw/master/md5.json
	#wget -q -c -P $tmpdir 'https://coding.net/u/adbyby/p/xwhyc-rules/git/raw/master/md5.json'
		if [ "$?"x != "0"x ]; then
			logger -t "${logger_title}" "获取在线规则时间失败" && exit 0     
		else
			lazy_local=$(grep 'lazy' local-md5.json | awk -F' ' '{print $1}')
			video_local=$(grep 'video' local-md5.json | awk -F' ' '{print $1}')  
			lazy_online=$(sed  's/":"/\n/g' md5.json  |  sed  's/","/\n/g' | sed -n '2p')
			video_online=$(sed  's/":"/\n/g' md5.json  |  sed  's/","/\n/g' | sed -n '4p')
			logger -t "${logger_title}"  "获取在线规则MD5成功，正在判断是否有更新中"
			# sed -i "s/=video,lazy/=none/g" /etc/storage/adb/adhook.ini
			# sed -i "s/=video,lazy/=none/g" /etc/storage/adb/adhook.sample.ini
			judge_update
		fi
		
