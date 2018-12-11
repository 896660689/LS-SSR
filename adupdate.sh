#!/bin/sh

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
		if [ ! -f $tmpdir/lazy.txt ]; then
		wget --no-check-certificate https://raw.githubusercontent.com/adbyby/xwhyc-rules/master/lazy.txt -O $tmpdir/lazy.txt;chmod 775 $tmpdir/lazy.txt
		cat $tmpdir/lazy.txt $adbyby_data/lazy.txt | awk '{ print$0}' | sort | uniq -u > $tmpdir/lazy_1.txt && sleep 2
		if [ ! -s "/tmp/hsfq_script_up.txt" ]; then
			echo -e "\e[1;33m lazy 规则已为最新,无需更新.\e[0m\n" && rm -f $tmpdir/lazy.txt && rm -f $tmpdir/lazy_1.txt
		else
			rm -f $adbyby_data/lazy.txt
			cp -f $tmpdir/lazy.txt $adbyby_data/lazy.txt
			mv -f $tmpdir/lazy.txt $adbyby_data/lazy.txt && rm -f $tmpdir/lazy_1.txt
			echo -e "\033[41;37m lazy 规则更新完成\033[0m\n" && sleep 3
		fi
	fi

	logger -t "${logger_title}" "自动检测规则更新中" && cd $tmpdir
		if [ ! -f $tmpdir/video.txt ]; then
		wget --no-check-certificate https://raw.githubusercontent.com/adbyby/xwhyc-rules/master/video.txt -O $tmpdir/video.txt;chmod 775 $tmpdir/video.txt
		cat $tmpdir/video.txt $adbyby_data/video.txt | awk '{ print$0}' | sort | uniq -u > $tmpdir/lazy_1.txt && sleep 2
		if [ ! -s "/tmp/hsfq_script_up.txt" ]; then
			echo -e "\e[1;33m video 规则已为最新,无需更新.\e[0m\n" && rm -f $tmpdir/video.txt && rm -f $adbyby_data/video_1.txt
		else
			rm -f $adbyby_data/video.txt
			cp -f $tmpdir/video.txt $adbyby_data/video.txt
			mv -f $tmpdir/video.txt $adbyby_data/video.txt && rm -f $adbyby_data/video_1.txt
			echo -e "\033[41;37m video 规则更新完成\033[0m\n" && sleep 3
		fi
	fi
