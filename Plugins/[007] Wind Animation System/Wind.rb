module Events
  module Animations
    class Wind
      SPEED = 12

      # @return [Integer]
      attr_accessor :x
      # @return [Integer]
      attr_accessor :y
      # @return [Integer]
      attr_accessor :z
      # @return [Integer]
      attr_accessor :ex
      # @return [Integer]
      attr_accessor :ey
      # @return [Integer]
      attr_accessor :opacity

      # @param viewport [Viewport]
      def initialize(viewport)
        @viewport = viewport
        @sprites = SpriteHash.new(viewport)
        @x = 0
        @y = 0
        @z = 0
        @ex = 0
        @ey = 0
        @opacity = 255

        sprites.add(0, bitmap: 'Graphics/Animations/Wind/wind1')
        sprites[0].src_rect.width = 0
        sprites[0].src_rect.x = sprites[0].bitmap.width
        sprites[0].oy = sprites[0].bitmap.height
        sprites[0].toggle = 1
        sprites[0].visible = true
        sprites[0].z = 100
        
        sprites.add(1, bitmap: 'Graphics/Animations/Wind/wind2')
        sprites[1].src_rect.height = 0
        sprites[1].src_rect.y = sprites[1].bitmap.height
        sprites[1].ox = sprites[1].bitmap.width
        sprites[1].toggle = 1
        sprites[1].visible = true
        sprites[1].z = 100
        
        sprites.add(2, bitmap: 'Graphics/Animations/Wind/wind3')
        sprites[2].src_rect.height = 0
        sprites[2].end_y = sprites[2].bitmap.height
        sprites[2].ox = sprites[2].bitmap.width
        sprites[2].toggle = 1
        sprites[2].visible = true
        sprites[2].z = 100
      end

      # Checks if sprite finished animating?
      # @return [Boolean]
      def finished?
        sprites.each_sprite do |sprite|
          return false unless sprite.toggle > 2
        end

        true
      end

      # Dispose sprites
      def dispose
        sprites.dispose
      end

      # @return [Boolean]
      def disposed?
        sprites.disposed?
      end

      # @param val [Boolean]
      def visible=(val)
        sprites.each_sprite { |sprite| sprite.visible = val }
      end

      # Updates sprites
      def update
        return if disposed?

        sprites.update

        # Handle beginning of swirl
        case sprites[0].toggle
        when 1
          sprites[0].ex += SPEED
          sprites[0].src_rect.width = sprites[0].ex.to_i
          sprites[0].end_x = sprites[0].width
          sprites[0].src_rect.x = sprites[0].bitmap.width - sprites[0].width
          sprites[0].toggle = 2 if sprites[0].width >= sprites[0].bitmap.width
        when 2
          sprites[0].ex -= SPEED
          sprites[0].src_rect.width = sprites[0].ex.to_i
          sprites[0].toggle = 3 if sprites[0].width <= 0
        end

        # Handle loop at the swirl
        if sprites[0].width >= 280 || sprites[0].toggle > 1
          case sprites[1].toggle
          when 1
            sprites[1].ey += SPEED
            sprites[1].src_rect.height = sprites[1].ey.to_i
            sprites[1].end_y = sprites[1].height
            sprites[1].src_rect.y = sprites[1].bitmap.height - sprites[1].height
            sprites[1].toggle = 2 if sprites[1].height >= sprites[1].bitmap.height
          when 2
            sprites[1].ey -= SPEED
            sprites[1].src_rect.height = sprites[1].ey.to_i
            sprites[1].toggle = 3 if sprites[1].height <= 0
          end
        end

        # Handle tail of the swirl
        if sprites[1].toggle > 1
          case sprites[2].toggle
          when 1
            sprites[2].ey += SPEED
            sprites[2].src_rect.height = sprites[2].ey.to_i
            sprites[2].toggle = 2 if sprites[2].height >= sprites[2].bitmap.height
          when 2
            sprites[2].ey -= SPEED
            sprites[2].src_rect.height = sprites[2].ey.to_i
            sprites[2].end_y = sprites[2].height
            sprites[2].src_rect.y = sprites[2].bitmap.height - sprites[2].height
            sprites[2].toggle = 3 if sprites[2].height <= 0
          end
        end

        sprites.each_sprite do |sprite|
          sprite.x = @ex + @x + sprite.bitmap.width - sprite.end_x
          sprite.y = @ey + @y + sprite.bitmap.height - sprite.end_y
          sprite.z = @z
          sprite.opacity = @opacity
        end
      end

      private

      # @return [SpriteHash]
      attr_reader :sprites
    end
  end
end
