require 'reek'
require 'reek/cli/options'
require 'reek/source/source_locator'

module Danger
  # Lints Ruby files via [Reek](https://rubygems.org/gems/reek).
  # Results are sent as inline comments.
  #
  # @example Running Reek
  #
  #          # Runs Reek on modified and added files in the PR
  #          reek.lint
  #
  # @see  blooper05/danger-reek
  # @tags ruby, reek, lint
  class DangerReek < Plugin
    # Runs Ruby files through Reek.
    # @return [Array<Reek::SmellWarning, nil>]
    def lint(files)
      files_to_lint = fetch_files_to_lint(files)
      code_smells   = run_linter(files_to_lint)
      warn_each_line(code_smells)
    end

    private

    def run_linter(files_to_lint)
      configuration = ::Reek::Configuration::AppConfiguration.from_path(nil)
      files_to_lint.flat_map do |file|
        examiner = ::Reek::Examiner.new(file, configuration: configuration)
        examiner.smells
      end
    end

    def fetch_files_to_lint(files)
      to_lint = (files ? Dir.glob(files) : (git.modified_files + git.added_files))
      ::Reek::Source::SourceLocator.new(to_lint).sources
    end

    def warn_each_line(code_smells)
      code_smells.each do |smell|
        message = smell.message.capitalize
        source  = smell.source
        smell.lines.each do |line|
          warn(message, file: source, line: line)
        end
      end
    end
  end
end
