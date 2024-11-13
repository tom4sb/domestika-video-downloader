# Libraries
require "csv"
require "optparse"

# Options
arguments = {}
OptionParser.new do |options|
    options.banner = "Domestika video downloader script accepts the following command-line options:"

    options.on(
        "--file FILE_NAME",
        "Specifies the file to process by its name.") do |file_name|
            arguments[:file] = file_name
    end

    options.on(
        "--dir DIRECTORY_PATH",
        "Specifies the directory's path that contains the files to process.") do |directory_path|
            arguments[:dir] = directory_path
    end

    options.on(
        "-h",
        "--help",
        "Prints a summary of the options.") do
            puts options
            exit
    end
end.parse!

# Constants
OUTPUT_PATH = "./output"

# String templates
FFMPEG_COMMAND_TEMPLATE = "ffmpeg -i \"%{m3u8_file_url}\" -c copy \"%{course_output_path}/%{mp4_file_name}.mp4\""
MKDIR_COMMAND_TEMPLATE = "mkdir -p \"%{course_output_path}\""
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
def process_file(file)
    course_csv_file = File.new(file.to_s, "r")
    course_output_path = build_course_output_path(course_csv_file)
    video_infos = load_video_infos(course_csv_file)
    create_course_output_directory(course_output_path)
    save_videos(video_infos, course_output_path)
end

def build_course_output_path(course_csv_file)
    course_title = capitalize_words(File.basename(course_csv_file, ".csv"))
    "#{OUTPUT_PATH}/#{course_title}"
end

def load_video_infos(course_csv_file)
    video_infos = Array.new
    CSV.foreach(course_csv_file, headers: false) { |row| video_infos << VideoInfo.new(*row) }
    video_infos
end

def create_course_output_directory(course_output_path)
    mkdir_command = MKDIR_COMMAND_TEMPLATE % { course_output_path: course_output_path }
    %x[#{mkdir_command}]
end

def save_videos(video_infos, course_output_path)
    video_infos.each do |video_info|
        mp4_file_name = MP4_FILE_NAME_TEMPLATE % {
            video_number: video_info.number.rjust(2, "0"),
            video_title: capitalize_words(video_info.title)
        }
        ffmpeg_command = FFMPEG_COMMAND_TEMPLATE % {
            m3u8_file_url: video_info.m3u8_url,
            course_output_path: course_output_path,
            mp4_file_name: mp4_file_name
        }
        %x[#{ffmpeg_command}]
    end
end

def capitalize_words(string)
    string.split(' ').map(&:capitalize).join(' ')
end

##############
### Script ###
##############

Dir["./input/*"].each(&method(:process_file))
