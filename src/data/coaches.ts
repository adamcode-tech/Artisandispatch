import { Coach } from '../types/coach';

export const coaches: Coach[] = [
  {
    id: '1',
    name: 'Sophie Martin',
    specialty: 'Fitness & Nutrition',
    rating: 4.9,
    reviews: 127,
    price: 65,
    image: 'https://images.unsplash.com/photo-1594381898411-846e7d193883?w=800',
    description: 'Coach certifiée avec 7 ans d\'expérience en transformation physique et nutrition sportive.',
    latitude: 48.8566,
    longitude: 2.3522
  },
  {
    id: '2',
    name: 'Thomas Dubois',
    specialty: 'Business Coaching',
    rating: 4.8,
    reviews: 89,
    price: 85,
    image: 'https://images.unsplash.com/photo-1556157382-97eda2d62296?w=800',
    description: 'Expert en développement professionnel et stratégie d\'entreprise.',
    latitude: 48.8584,
    longitude: 2.3536
  },
  {
    id: '3',
    name: 'Emma Laurent',
    specialty: 'Life Coaching',
    rating: 4.9,
    reviews: 156,
    price: 75,
    image: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=800',
    description: 'Spécialiste en développement personnel et gestion du stress.',
    latitude: 48.8606,
    longitude: 2.3376
  }
];