class MacrosController < ApplicationController
  def display_form
      render({ :template => "macro_templates/new_form"})
  end

  def process_inputs
    @image = params.fetch("image_param")
    @data_uri = DataURI.convert(@image)

    @description = params.fetch("description_param")

    c = OpenAI::Chat.new
    c.system("You are an expert nutritionist. Estimate the macronutrients (carbohydrates, protein, and fat) in games, as well as total calories in kcal.")
    c.user(@description, image: @image)

    c.schema = '{
      "name": "nutrition_info",
      "schema": {
        "type": "object",
        "properties": {
          "carbohydrates": {
            "type": "number",
            "description": "Amount of carbohydrates in grams."
          },
          "protein": {
            "type": "number",
            "description": "Amount of protein in grams."
          },
          "fat": {
            "type": "number",
            "description": "Amount of fat in grams."
          },
          "total_calories": {
            "type": "number",
            "description": "Total calories in kcal."
          },
          "notes": {
            "type": "string",
            "description": "A breakdown of how you arrived at the values, and additional notes."
          }
        },
        "required": [
          "carbohydrates",
          "protein",
          "fat",
          "total_calories",
          "notes"
        ],
        "additionalProperties": false
      },
      "strict": true
    }'
    c.model = 'o3'
    @result = c.assistant!

    render({ :template => "macro_templates/processed_form"})
  end
end
