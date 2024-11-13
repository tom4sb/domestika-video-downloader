# Libraries
require "csv"
require "optparse"

# Constants
DIR_OPTION_MESSAGE = "Specifies the directory's path that contains the files to process."
FILE_OPTION_MESSAGE = "Specifies the file to process by its name."
HELP_OPTION_MESSAGE = "Prints a summary of the options."
MISSING_ARGUMENT_ERROR_MESSAGE = "Missing argument. Use -h or --help for more information."
NO_OPTION_ERROR_MESSAGE =
    "You must specify a file or a directory to process. Use -h or --help for more information."
OPTIONS_BANNER_MESSAGE =
    "Domestika video downloader script accepts the following command-line options:"

CSV_FILE_EXTENSION = ".csv"
OUTPUT_PATH = "./output"

FFMPEG_COMMAND_TEMPLATE =
    "ffmpeg -i \"%{m3u8_file_url}\" -c copy \"%{course_output_path}/%{mp4_file_name}.mp4\""
MKDIR_COMMAND_TEMPLATE = "mkdir -p \"%{course_output_path}\""
MP4_FILE_NAME_TEMPLATE = "[%{video_number}] %{video_title}"

# Options
options = {}
begin
    OptionParser.new do |accepted_options|
        accepted_options.banner = OPTIONS_BANNER_MESSAGE
        accepted_options.on("--file file_name", FILE_OPTION_MESSAGE) do |file_name|
            options[:file] = file_name
        end
        accepted_options.on("--dir directory_path", DIR_OPTION_MESSAGE) do |directory_path|
            options[:dir] = directory_path
        end
        accepted_options.on("-h", "--help", HELP_OPTION_MESSAGE) do
            puts accepted_options
            exit
        end
    end.parse!
rescue OptionParser::MissingArgument => e
    puts MISSING_ARGUMENT_ERROR_MESSAGE
    exit(1)
end

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
    return unless File.extname(file) == CSV_FILE_EXTENSION

    course_csv_file = File.new(file.to_s, "r")
    course_output_path = build_course_output_path(course_csv_file)
    video_infos = load_video_infos(course_csv_file)
    create_course_output_directory(course_output_path)
    save_videos(video_infos, course_output_path)
end

def build_course_output_path(course_csv_file)
    course_title = capitalize_words(File.basename(course_csv_file, CSV_FILE_EXTENSION))
    "#{OUTPUT_PATH}/#{course_title}"
end

def load_video_infos(course_csv_file)
    video_infos = []
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

######################################################################
############################### Script ###############################
######################################################################

if options[:file]
    process_file(options[:file])
elsif options[:dir]
    Dir["#{options[:dir]}/*"].each(&method(:process_file))
else
    puts NO_OPTION_ERROR_MESSAGE
end
