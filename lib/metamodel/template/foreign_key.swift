<% model.relation_properties.each do |property| %><% if property.has_many? %>
<%= """public extension #{model.name} {
    func append#{property.type}(element: #{property.type}) {
        var element = element
        element.update(#{model.foreign_id}: id)
    }

    func create#{property.type}(#{property.relation_model.property_key_type_pairs_without_property model.foreign_id}) -> #{property.type}? {
        return #{property.type}.create(#{property.relation_model.property_key_value_pairs_without_property model.foreign_id}, #{model.foreign_id}: self.id)
    }

    func delete#{property.type}(id: Int) {
        #{property.type}.filter(.#{model.foreign_id}, value: id).findBy(id: id).first?.delete
    }
    var #{property.name}: [#{property.type}] {
        get {
            return #{property.type}.filter(.id, value: id).result
        }
        set {
            #{property.name}.forEach { (element) in
                var element = element
                element.update(#{model.foreign_id}: 0)
            }
            newValue.forEach { (element) in
                var element = element
                element.update(#{model.foreign_id}: id)
            }
        }
    }
}""" %><% elsif property.belongs_to? %>
<%= """public extension #{model.name} {
    var #{property.name}: #{property.type}? {
        get {
            return #{property.type}.find(id)
        }
        set {
            guard let newValue = newValue else { return }
            update(#{property.type.camelize(:lower)}Id: newValue.id)
        }
    }

}""" %><% elsif property.has_one? %>
<%= """public extension #{model.name} {
    var #{property.name}: #{property.type}? {
        get {
            return #{property.type}.find(id)
        }
        set {
            #{property.type}.filter(.#{model.name.camelize(:lower)}Id, value: id).deleteAll
            guard var newValue = newValue else { return }
            newValue.update(articleId: id)
        }
    }
}"""%><% end %><% end %>
