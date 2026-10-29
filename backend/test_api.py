from app.main import WardSnapshot, calculate_risk


def test_zero_occupancy_is_low_risk():
    snapshot = WardSnapshot(ward_name="Demo", total_beds=10, available_beds=10,
                            occupied_beds=0, booked_beds=0, cleaning_beds=0)
    assert calculate_risk(snapshot) == (0.0, "low")


def test_high_occupancy_is_high_risk():
    snapshot = WardSnapshot(ward_name="Demo", total_beds=10, available_beds=1,
                            occupied_beds=9, booked_beds=0, cleaning_beds=0)
    assert calculate_risk(snapshot) == (90.0, "high")
