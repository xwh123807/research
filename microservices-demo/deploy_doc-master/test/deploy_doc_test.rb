require 'test_helper'
require 'deploy_doc'

class DeployDocTest < Minitest::Test
  def test_parsing_annotations
    annotations = DeployDoc::TestPlan::AnnotationParser.parse(unindent(6, <<-EOD))
      ---
      deployDoc: true
      ---
      # Hello There
      <!-- deploy-doc-start block-A-kind params -->

          Content of first block

      <!-- deploy-doc-end -->

      <!-- deploy-doc block-B-kind A=B C=D -->
    EOD

    assert_equal 2, annotations.length

    annotation_A = annotations.first
    assert_equal annotation_A.kind, "block-A-kind"
    assert_equal annotation_A.params, ["params"]
    assert_equal annotation_A.content.strip, "Content of first block"

    annotation_B = annotations.last
    assert_equal annotation_B.kind, "block-B-kind"
    assert_equal annotation_B.params, ["A=B", "C=D"]
    assert_equal annotation_B.content, nil
  end

  def test_parsing_test_plan
    test_plan = DeployDoc::TestPlan.from_str(unindent(6,<<-END))
      ---
      deployDoc: true
      ---

      # Test plan
      
      <!-- deploy-doc require-env ENV_A ENV_B -->
      <!-- deploy-doc-start pre-install -->

        Deploy doc pre-install

      <!-- deploy-doc-end -->
    END

    assert_equal test_plan.required_env_vars, ["ENV_A", "ENV_B"]
    assert_equal test_plan.required_env_vars, ["ENV_A", "ENV_B"]
    assert_equal test_plan.steps_in_phases["pre-install"].length, 1
    assert_equal test_plan.steps_in_phases["pre-install"].first.shell.strip, "Deploy doc pre-install"
  end

  def unindent(amount, input)
    input.gsub(/^#{" " * amount}/, "")
  end
end
