version: 2
sources:
  - name: raw
    description: Raw data loaded from NYC Open Data
    database: victorchen-cis-9440-uta
    schema: nyc_311_raw_data 
    tables:
      - name: source_dot_service_requests_history
        description: |
          NYC 311 service requests for Dept of Transportation.
          One row per service request.
        columns:
          - name: unique_key
            description: Unique ID for the service request
            tests:
              - unique
              - not_null
          - name: created_date
            description: Date and time the request was created
          - name: closed_date
            description: Date and time the request was closed
          - name: agency
            description: Agency code
          - name: agency_name
            description: Full name of the agency
          - name: complaint_type
            description: Type of complaint
          - name: descriptor
            description: Further description of the complaint
          - name: descriptor_2
            description: Additional description of the complaint
          - name: location_type
            description: Location where the incident occurred
          - name: incident_zip
            description: Zip code of the incident location
          - name: incident_address
            description: Street address of the incident
          - name: latitude
            description: Latitude coordinate
          - name: longitude
            description: Longitude coordinate
          - name: address_type
            description: 'Type of address (e.g., ADDRESS, INTERSECTION, BLOCKFACE)'
          - name: bbl
            description: Borough Block and Lot number (NYC tax lot id)
          - name: borough
            description: NYC borough where incident occurred
          - name: bridge_highway_direction
            description: Direction on bridge or highway (e.g. Northbound)
          - name: bridge_highway_name
            description: Name of bridge or highway where incident occurred
          - name: bridge_highway_segment
            description: Specific segment of bridge or highway
          - name: city
            description: City name where incident occurred
          - name: community_board
            description: NYC Community Board district number
          - name: cross_street_1
            description: First cross street near incident location
          - name: cross_street_2
            description: Second cross street near incident location
          - name: due_date
            description: Expected due date for request resolution
          - name: facility_type
            description: Type of facility where incident occurred
          - name: intersection_street_1
            description: First street forming intersection where incident occurred
          - name: intersection_street_2
            description: Second street forming intersection where incident occurred
          - name: open_data_channel_type
            description: How request was submitted (ONLINE, PHONE, MOBILE, etc.)
          - name: park_borough
            description: Borough of park where incident occurred
          - name: park_facility_name
            description: Name of park facility where incident occurred
          - name: resolution_action_updated_date
            description: Date when resolution action was last updated
          - name: resolution_description
            description: Description of how the request was resolved
          - name: road_ramp
            description: Road ramp identifier where incident occurred
          - name: status
            description: Current status of request (Open, Closed, In Progress, etc.)
          - name: street_name
            description: Name of street where incident occurred
          - name: x_coordinate_state_plane
            description: X coordinate in NY State Plane projection system (NAD 83)
          - name: y_coordinate_state_plane
            description: Y coordinate in NY State Plane projection system (NAD 83)
          - name: landmark
            description: Nearby landmark or point of interest

      - name: source_nyc_open_restaurant_apps
        description: |
          Raw NYC Open Restaurants applications data.
          One row per restaurant application record.
        columns:
          - name: approved_for_roadway_seating
            description: Indicates whether the application was approved for roadway seating
          - name: approved_for_sidewalk_seating
            description: Indicates whether the application was approved for sidewalk seating
          - name: bbl
            description: Borough Block and Lot number for the property
          - name: bin
            description: Building Identification Number
          - name: borough
            description: NYC borough where the restaurant is located
          - name: bulding_number
            description: Building number of the restaurant address
          - name: business_address
            description: Business address of the restaurant
          - name: census_tract
            description: Census tract where the restaurant is located
          - name: community_board
            description: NYC Community Board district number
          - name: council_district
            description: NYC Council district number
          - name: doing_business_as_dba
            description: Doing business as name of the restaurant
          - name: food_service_establishment
            description: Food service establishment identifier or status
          - name: globalid
            description: Global identifier for the application record
          - name: healthcompliance_terms
            description: Health compliance terms associated with the application
          - name: landmark_district_or_building
            description: Indicates whether the restaurant is in a landmark district or building
          - name: landmarkdistrict_terms
            description: Landmark district terms associated with the application
          - name: latitude
            description: Latitude coordinate of the restaurant location
          - name: legal_business_name
            description: Legal business name of the applicant
          - name: longitude
            description: Longitude coordinate of the restaurant location
          - name: nta
            description: Neighborhood Tabulation Area code
          - name: objectid
            description: Object ID for the application record
          - name: qualify_alcohol
            description: Indicates whether the business qualifies for alcohol service
          - name: restaurant_name
            description: Name of the restaurant
          - name: roadway_dimensions_area
            description: Area of the roadway seating space
          - name: roadway_dimensions_length
            description: Length of the roadway seating space
          - name: roadway_dimensions_width
            description: Width of the roadway seating space
          - name: seating_interest_sidewalk
            description: Indicates interest in sidewalk seating
          - name: sidewalk_dimensions_area
            description: Area of the sidewalk seating space
          - name: sidewalk_dimensions_length
            description: Length of the sidewalk seating space
          - name: sidewalk_dimensions_width
            description: Width of the sidewalk seating space
          - name: sla_license_type
            description: SLA license type for the restaurant
          - name: sla_serial_number
            description: SLA serial number for the restaurant
          - name: street
            description: Street name of the restaurant address
          - name: time_of_submission
            description: Time when the application was submitted
          - name: zip
            description: ZIP code of the restaurant location