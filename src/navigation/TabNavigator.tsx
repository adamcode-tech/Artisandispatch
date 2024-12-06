import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import FindCoachScreen from '../screens/FindCoachScreen';

const Tab = createBottomTabNavigator();

function TabNavigator() {
  return (
    <Tab.Navigator>
      <Tab.Screen 
        name="FindCoach" 
        component={FindCoachScreen}
        options={{
          title: 'Trouver un coach',
        }}
      />
    </Tab.Navigator>
  );
}

export default TabNavigator; 