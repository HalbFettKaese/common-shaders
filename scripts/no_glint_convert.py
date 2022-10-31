from PIL import Image
from beet import ResourcePack, Texture, TextureMcmeta, Model

def __main__():
    rp = ResourcePack()
    rp.load("sourcePack")
    
    update_model("manic:open", rp)
    update_model("manic:closed", rp)

    rp.save(path="targetPack", overwrite=True)


def rename_texture(texture_id, model_id):
    return texture_id + "_" + model_id.replace(":",".").replace("/",".") + "_no_glint"

def enumerate_uvs(model, model_id):
    mappings = {}
    textures = model.data["textures"]
    new_textures = {}
    for i, element in enumerate(model.data.get("elements", [])):
        for dir, face in element.get("faces", {}).items():
            if (texture := face.get("texture")) and (uv := face.get("uv")):
                if texture == "#missing":
                    print(f"Element {i} has a #missing texture for face {dir}.")
                    continue
                if texture.startswith("#"):
                    new_texture = textures[texture[1:]]
                    new_textures[texture[1:]] = rename_texture(new_texture, model_id)
                    texture = new_texture
                else:
                    face["texture"] = rename_texture(texture, model_id)
                rotation = (face.get("rotation", 0) // 90) % 4
                uv = tuple([(uv[0], uv[1]), (uv[2], uv[1]), (uv[0], uv[3]), (uv[2], uv[3])])
                for _ in range(rotation):
                    uv = tuple(uv[j] for j in [2, 0, 3, 1])
                if texture not in mappings:
                    mappings[texture] = {}
                if uv not in mappings[texture]:
                    mappings[texture][uv] = set()
                if model_id == "manic:closed" and (i, dir) == (1, "down"):
                    print("Why?", element)
                mappings[texture][uv].add((i, dir))
    textures.update(new_textures)
    return mappings


def update_texture(mappings, model, model_id, rp):
    for texture, uvs in mappings.items():
        tex = rp[Texture][texture]
        mcmeta = rp[TextureMcmeta].get(texture)
        width = tex.image.width
        height = tex.image.height
        frame_count = 1
        single_frame_height = height
        if mcmeta:
            animation = mcmeta.data.get("animation", {})
            single_frame_height = animation.get("height", width)
            frame_count = height // single_frame_height
        uv_region_size = len(uvs) * 4
        outer_width, outer_height = width, height
        double_width = width <= height
        while outer_width * outer_height < width * height + uv_region_size:
            if double_width or mcmeta:
                outer_width *= 2
            else:
                outer_height *= 2
            double_width = not double_width
        gen_tex = Image.new("RGBA", (outer_width, outer_height))
        gen_tex.paste(tex.image, (outer_width-width, outer_height-height, outer_width, outer_height))
        cursor_x = 0
        cursor_y = 0
        for uv, faces in uvs.items():
            uv = [(int(x/16 * width + outer_width - width), int((y/16 * height + outer_height - height)/frame_count)) for x, y in uv]
            for frame in range(frame_count):
                frame_offset_y = int(frame * single_frame_height)
                gen_tex.putpixel((cursor_x  , cursor_y   + frame_offset_y), ((uv[0][0]-cursor_x) % 256, (uv[0][1]-cursor_y) % 256, 1, 249))
                gen_tex.putpixel((cursor_x+1, cursor_y   + frame_offset_y), ((uv[1][0]-cursor_x) % 256, (uv[1][1]-cursor_y) % 256, 1, 249))
                gen_tex.putpixel((cursor_x  , cursor_y+1 + frame_offset_y), ((uv[2][0]-cursor_x) % 256, (uv[2][1]-cursor_y) % 256, 1, 249))
                gen_tex.putpixel((cursor_x+1, cursor_y+1 + frame_offset_y), ((uv[3][0]-cursor_x) % 256, (uv[3][1]-cursor_y) % 256, 1, 249))
            model_uv = [((x+0.5)*16 / outer_width, (y+0.5)*16 / outer_height / frame_count) for x, y in [(cursor_x, cursor_y), (cursor_x+1, cursor_y)]]
            for (i, face) in faces:
                try:
                    target = model.data["elements"][i]["faces"][face]
                except:
                    print(model_id, i, face)
                target["uv"] = [*model_uv[0], *model_uv[1]]
                if "rotation" in target:
                    target.pop("rotation")
            cursor_x += 2
            if (cursor_y + 1 >= outer_height - height and cursor_x + 1 >= outer_width - width) \
                or cursor_x + 1 >= outer_width:
                cursor_x = 0
                cursor_y += 2
        new_texture_id = rename_texture(texture, model_id)
        rp[Texture][new_texture_id] = Texture(gen_tex)
        if mcmeta:
            rp[TextureMcmeta][new_texture_id] = mcmeta


def update_model(model_id, rp):
    model = rp[Model][model_id]
    mappings = enumerate_uvs(model, model_id)
    update_texture(mappings, model, model_id, rp)

if __name__ == "__main__":
    __main__()
