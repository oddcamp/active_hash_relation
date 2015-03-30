module ActiveHashRelation::LimitFilters
  def apply_limit(resource, limit)
    return resource.limit(limit)
  end
end
