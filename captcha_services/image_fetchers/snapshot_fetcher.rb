

module SnapShotFetcher

    def valid_snapshot_connection?()
        return false if !var_exists?(:agent)
        return false if share_get(:agent).class.to_s != 'RemoteConnectorClass'
        share_get(:agent).conn
    end

    def save_snapshot(coords)
        if (conn = valid_snapshot_connection?)

           info("[Captcha Solver] -- Saving Snapshot Using Coords: #{coords.inspect}")
           begin
               snapshot_filename = conn.save_screen("snapshot-#{rand(999999)}")

               image = ImageScience.with_image( snapshot_filename )
               delete_file_if_exists(snapshot_filename) #<--- clean out captcha snapshot

               info("[Captcha Solver] -- Loaded SnapShot Image: Width/Height [ #{image.width} / #{image.height} ]")

               new_image = image.with_crop( *coords )
               captcha_filename = "#{CaptchaDirectory}captcha_cropped-#{rand(99999)}.png"
               new_image.save( captcha_filename )

               share_add({:captcha_file => captcha_filename}, true)

               info("[Captcha Solver] -- Finished Saving SnapShot...")

               set_finished()
           rescue => err
               error("[Captcha Solver] -- Error Creating Captcha SnapShot : #{err.message}")
           end

        else
           error("[Captcha Solver] -- Cannot Create Snapshot no Valid Connection Available.")
        end
    end

    def fetch_snapshot()
        #share_add({:captcha_file => filename}, true)
        begin
           coords = @args[:image_coords].split(',').map{ |coord| Integer(coord) }
        rescue => err
           error("[Captcha Solver] -- Cannot Create SnapShot Invalid Coordinates Provided...")
        end

        save_snapshot(coords)
    end

end
