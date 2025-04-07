class EmbedBuilder {
    fields:=[]
    set_title(title) {
        this.title := title
        return this
    }
    set_description(description) {
        this.description := description
        return this
    }
    set_color(color) {
        this.color := color
        return this
    }
    set_footer(footerfunc) {
        footer := EmbedBuilder.Footer()
        (footerfunc)(footer)
        this.footer := footer
        return this
    }
    set_image(image_url) {
        this.image := { url: image_url }
        return this
    }
    set_thumbnail(thumbnail_url) {
        this.thumbnail := { url: thumbnail_url }
        return this
    }
    set_author(authorfunc) {
        author := EmbedBuilder.Author()
        (authorfunc)(author)
        this.author := author
        return this
    }
    add_field(name, value, inline := false) {
        field := { name: name, value: value, inline: inline, base: { __Class: 'EmbedField', to_string: field_to_string } }
        this.fields.push(field)
        return this

        field_to_string(self) {
            str := '{"name":"' self.name '","value":"' self.value '"'
            if self.inline
                str .= ',"inline":true'
            str .= '}'
            return str
        }
    }
    add_fields(fields*) {
        if fields.length == 1 && fields[1] is Array {
            fields := fields[1]
        }
        for field in fields
            this.add_field(field.name, field.value, field.inline)
        return this
    }

    to_string() {
        str := '{'
        if this.HasProp('title')
            str .= '"title":"' this.title '"'
        if this.HasProp('description')
            str .= ',"description":"' this.description '"'
        if this.HasProp('color')
            str .= ',"color":' this.color
        if this.HasProp('footer')
            str .= ',"footer":' this.footer.to_string()
        if this.HasProp('image')
            str .= ',"image":{"url":"' this.image.url '"}'
        if this.HasProp('thumbnail')
            str .= ',"thumbnail":{"url":"' this.thumbnail.url '"}'
        if this.HasProp('author')
            str .= ',"author":' this.author.to_string()
        if (this.fields.Length) {
            str .= ',"fields":['
            for i, field in this.fields {
                str .= field.to_string()
                if (i < this.fields.Length)
                    str .= ','
            }
            str .= ']'
        }
        str .= '}'
        return str
    }

    set_timestamp(timestamp?) {
        if !IsSet(timestamp) {
            this.timestamp := FormatTime(A_NowUTC, "yyyy-MM-ddTHH:mm:ss.000Z")
            return this
        }
        if !RegExMatch(timestamp, "i)\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}")
            throw "Invalid timestamp format. Use 'yyyy-MM-ddTHH:mm:ss'"
        this.timestamp := timestamp
        return this
    }
    set_url(url) {
        this.url := url
        return this
    }
    class Footer {
        to_string() {
            str := '{'
            if this.HasProp('text')
                str .= '"text":"' this.text '"'
            if this.HasProp('icon_url')
                str .= ',"icon_url":"' this.icon_url '"'
            str .= '}'
            return str
        }
        set_text(text) {
            this.text := text
            return this
        }
        set_icon_url(icon_url) {
            this.icon_url := icon_url
            return this
        }
    }
    class Author {
        to_string() {
            str := '{'
            if this.HasProp('name')
                str .= '"name":"' this.name '"'
            if this.HasProp('icon_url')
                str .= ',"icon_url":"' this.icon_url '"'
            if this.HasProp('url')
                str .= ',"url":"' this.url '"'
            str .= '}'
            return str
        }
        set_name(name) {
            this.name := name
            return this
        }
        set_icon_url(icon_url) {
            this.icon_url := icon_url
            return this
        }
        set_url(url) {
            this.url := url
            return this
        }
    }
}
