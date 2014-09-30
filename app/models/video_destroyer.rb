class VideoDestroyer
  def initialize(video)
    @video = video
  end
  def destroy(&block)
    BW::HTTP.delete(@video.url) do |response|
      if response.ok?
        @video.destroy 
        block.call
      end
    end
  end
end