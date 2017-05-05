require "jobs/rubocop_review_job"

RSpec.describe RubocopReviewJob do
  include LintersHelper

  context "when file contains violations" do
    it "reports violations" do
      content = <<~EOS
        # frozen_string_literal: true
        def foo(bar:, baz:)
          bar
        end
      EOS

      expect_violations_in_file(
        content: content,
        filename: "foo/test.rb",
        violations: [
          {
            line: 2,
            message: "Unused method argument - baz.",
          },
        ],
      )
    end
  end

  context "when custom configuration is provided" do
    context "and outdated Rubocop rule is used" do
      it "reports the invalid config" do
        config = <<~YAML
          Style/SpaceBeforeModifierKeyword:
            Enabled: true
        YAML

        content = <<~EOS
          # frozen_string_literal: true
          def foo(bar:, baz:)
            bar
          end
        EOS

        attributes = {
          "config" => config,
          "content" => content,
          "commit_sha" => "anything",
          "filename" => "foo/test.rb",
          "patch" => "",
          "linter_name" => "rubocop",
          "pull_request_number" => "1",
        }
        allow(Resque).to receive(:enqueue)

        RubocopReviewJob.perform(attributes)

        expect(Resque).to have_received(:enqueue).with(
          ReportInvalidConfigJob,
          pull_request_number: attributes["pull_request_number"],
          commit_sha: attributes["commit_sha"],
          linter_name: attributes["linter_name"],
          message: "The `Style/SpaceBeforeModifierKeyword` cop has been removed. Please use `Style/SpaceAroundKeyword` instead.",
        )
      end
    end

    context "and directory is excluded" do
      it "reports no violations" do
        config = <<~YAML
          AllCops:
            Exclude:
              - "foo/*.rb"
        YAML

        expect_violations_in_file(
          config: config,
          content: "def yo;   42 end",
          filename: "foo/test.rb",
          violations: [],
        )
      end
    end

    context "and new ruby syntax is used" do
      it "reports relevant violations" do
        config = <<~YAML
          AllCops:
            Exclude:
              - Rakefile
        YAML
        content = <<~EOS
          # frozen_string_literal: true
          def foo(bar:, baz:)
            bar
          end
        EOS

        expect_violations_in_file(
          config: config,
          content: content,
          filename: "foo/test.rb",
          violations: [
            {
              line: 2,
              message: "Unused method argument - baz.",
            },
          ],
        )
      end
    end
  end

  context "when syntax is invalid" do
    it "reports an error as violation" do
      expect_violations_in_file(
        content: "def yo 42 end",
        filename: "foo/test.rb",
        violations: [
          {
            line: 1,
            message: "unexpected token tINTEGER",
          },
        ],
      )
    end
  end
end
