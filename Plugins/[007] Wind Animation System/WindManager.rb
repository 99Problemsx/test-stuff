module Events
  module Animations
    class WindManager
      MAX_PARTICLES = 2  # Maximum number of wind particles at a time

      def initialize(viewport)
        @viewport = viewport
        @particles = []
        @spawn_timer = 0
        @spawn_delay = rand(60..120)  # Random delay between spawns
      end

      def dispose
        @particles.each { |particle| particle.dispose }
        @particles.clear
      end

      def disposed?
        @particles.empty?
      end

      def update
        # Remove finished particles
        @particles.delete_if do |particle|
          if particle.finished?
            particle.dispose
            true
          else
            false
          end
        end

        # Spawn new particles if we're below the limit
        @spawn_timer += 1
        if @spawn_timer >= @spawn_delay && @particles.length < MAX_PARTICLES
          spawn_particle
          @spawn_timer = 0
          @spawn_delay = rand(60..120)
        end

        # Update existing particles
        @particles.each { |particle| particle.update }
      end

      private

      def spawn_particle
        particle = Wind.new(@viewport)
        
        # Random starting position (on-screen, visible)
        particle.x = rand(0..Graphics.width)
        particle.y = rand(0..Graphics.height)
        particle.ex = 0
        particle.ey = 0
        particle.z = 100
        particle.opacity = 255
        particle.visible = true
        
        @particles.push(particle)
      end
    end
  end
end
