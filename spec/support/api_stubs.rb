module ApiStubs
  def successful_response
    {
      :status => 200,
      :body => {
        "birth_date" => "1972-01-01T00:00:00",
        "family_name" => "\u064a\u0647",
        "father_name" => "\u062a\u064a\u0642",
        "first_name" => "\u062d\u0646",
        "gender" => "F",
        "grandfather_name" => "\u0645\u0635\u0641\u0649",
        "mother_name" => "\u062e\u062f\u064a\u062c\u0647 \u062c\u0648\u064a\u0644\u0649 \u0627\u062d\u0645\u064a\u062f\u0647",
        "national_id" => 118000023427,
        "registry_number" => 2231520
      }
    }
  end

  def unsuccessful_response
    {
      :status => 404
    }
  end
end
