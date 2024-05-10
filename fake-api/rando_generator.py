import random


def get_random_age(age_weights):
    # Create a list to store the age categories and their corresponding weights
    age_categories = []
    age_weights_cumulative = []

    # Initialize the cumulative weights
    cumulative_weight = 0

    # Iterate through age_weights to create cumulative weights
    for age_range, weight in age_weights.items():
        age_categories.append(age_range)
        cumulative_weight += weight
        age_weights_cumulative.append(cumulative_weight)
    num_samples = 1
    # Generate random ages based on the given weights
    random_ages = []
    for _ in range(num_samples):
        rand = random.random() * cumulative_weight
        for i, weight in enumerate(age_weights_cumulative):
            if rand < weight:
                random_ages.append(random.randint(*age_categories[i]))
                break

    return random_ages[0]


def get_random_country(country_probabilities):
    countries = list(country_probabilities.keys())
    probabilities = list(country_probabilities.values())
    random_countries = random.choices(countries, probabilities, k=1)
    return random_countries[0]


def get_random_gender(gender_probabilities):
    genders = list(gender_probabilities.keys())
    probabilities = list(gender_probabilities.values())
    random_genders = random.choices(genders, probabilities, k=1)
    return random_genders[0]
