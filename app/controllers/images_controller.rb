class ImagesController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:create]
  IMAGE_BUCKET_NAME = 'whiteboardify-images'

  def create
    current_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    object_name = current_time + ':' + params["title"]

    uploaded_to_s3 = upload_image_to_s3(
      image_path: './app/assets/images/SOMETHING.jpg',
      object_name: object_name,
    )

    head :internal_server_error unless uploaded_to_s3

    textract_results = run_textract_on_image(object_name: object_name)
    image_text = get_full_text_from(textract_results: textract_results)

    render json: {
      title: params["title"],
      s3_object_name: object_name,
      time: current_time,
      text: image_text
    }
  end

  private

  # returns boolean
  def upload_image_to_s3(image_path:, object_name:)
    s3 = Aws::S3::Resource.new
    s3.bucket(IMAGE_BUCKET_NAME).object(object_name).upload_file(image_path)
  end

  # returns Types::DetectDocumentTextResponse
  def run_textract_on_image(object_name:)
    client = Aws::Textract::Client.new
    client.detect_document_text({
      document: {
        s3_object: {
          bucket: IMAGE_BUCKET_NAME,
          name: object_name,
        },
      },
    })
  end

  # returns String
  def get_full_text_from(textract_results:)
    full_text = ''
    textract_results.blocks.each do |block|
      break if block.block_type == "WORD"

      if block.block_type == "LINE"
        full_text << ' ' << block.text
      end
    end

    full_text
  end

  def 
end
