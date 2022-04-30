# frozen_string_literal: true

module InfoHelper
  def question_answer(question, &)
    render 'info/question_answer', { question: }, &
  end
end
