# Libraries
require "csv"

# String templates
FFMPEG_COMMAND_TEMPLATE = "ffmpeg -i \"%{m3u8_file_url}\" -c copy \"./output/%{course_title}/%{mp4_file_name}.mp4\""
MKDIR_COMMAND_TEMPLATE = "mkdir \"./output/%{course_title}\""
MP4_FILE_NAME_TEMPLATE = "[%{video_number}] %{video_title}"

# Classes
class VideoInfo
    attr_reader :number, :title, :m3u8_url

    def initialize(number, title, m3u8_url)
        @number = number
        @title = title
        @m3u8_url = m3u8_url
    end
end

# Methods
def capitalize_words(string)
    string.split(' ').map(&:capitalize).join(' ')
end

##############
### Script ###
##############

Dir["./input/*"].each do |file|
    # Load CSV
    course_csv_file = File.new(file.to_s, "r")
    video_infos = Array.new
    CSV.foreach(course_csv_file, headers: false) { |row| video_infos << VideoInfo.new(*row) }

    # Create directory
    course_title = capitalize_words(File.basename(course_csv_file, ".csv"))
    mkdir_command = MKDIR_COMMAND_TEMPLATE % { course_title: course_title }
    %x[#{mkdir_command}]

    # Save videos
    video_infos.each do |video_info|
        m3u8_file_url = video_info.m3u8_url
        mp4_file_name = MP4_FILE_NAME_TEMPLATE % { video_number: video_info.number.rjust(2, "0"), video_title: capitalize_words(video_info.title) }
        ffmpeg_command = FFMPEG_COMMAND_TEMPLATE % { m3u8_file_url: m3u8_file_url, course_title: course_title, mp4_file_name: mp4_file_name }
        %x[#{ffmpeg_command}]
    end
end
